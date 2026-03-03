-- Copyright (C) 2023 Advanced Micro Devices, Inc.
-- SPDX-License-Identifier: MIT

library ieee, xpm;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_misc.all;
    use xpm.vcomponents.all;

entity shell_utils_ucc_v1_0_0_shutdown_latch is

    generic (
        C_ENABLE_SHUTDOWN_CLEARING : integer range 0 to 1     := 0
        );
    port (
        Clk                     : in    std_logic;
        Rst                     : in    std_logic;

        Request_SC              : in    std_logic;                      -- From SC Input pin
        Request_SW              : in    std_logic_vector(15 downto 0);  -- From Host GPIO
        Request_Gate_En         : in    std_logic;                      -- From CMC GPIO
        Request_Ack             : in    std_logic;                      -- From CMC GPIO
        Request_Latch           : out   std_logic;                      -- To CMC GPIO
        Shutdown_Latch          : out   std_logic                       -- To MMCM powerdown
    );
end entity shell_utils_ucc_v1_0_0_shutdown_latch;

architecture rtl of shell_utils_ucc_v1_0_0_shutdown_latch is

-------------------------------------------------------------------------------
--
--      Constants (simple)
--
-------------------------------------------------------------------------------

constant ZERO                  : std_logic_vector(0 downto 0)        := (others => '0');

constant SW_SHUTDOWN_MAGIC_NUM : std_logic_vector(Request_SW'RANGE)  := conv_std_logic_vector(56089, Request_SW'LENGTH);

-------------------------------------------------------------------------------
--
--      Type Definitions
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
--      Signals
--
-------------------------------------------------------------------------------

signal  Request_SC_cdc        : std_logic := '0';
signal  Request_SW_reduced    : std_logic := '0';
signal  Request               : std_logic := '0';
signal  Request_Latch_int     : std_logic := '0';
signal  Shutdown_Latch_int    : std_logic := '0';
signal  Shutdown_Release      : std_logic := '0';
signal  Request_Ack_d1        : std_logic := '0';

begin

-------------------------------------------------------------------------------
--
--      CDC the SC Shutdown Clocks Request
--
-------------------------------------------------------------------------------

CDC_SCR : xpm_cdc_single
    generic map (
        DEST_SYNC_FF    => 4,
        SRC_INPUT_REG   => 0
    )
    port map (
        src_clk     => ZERO(0),
        src_in      => Request_SC,

        dest_clk    => Clk,
        dest_out    => Request_SC_cdc
    );

-------------------------------------------------------------------------------
--
--      Latch Logic
--
-------------------------------------------------------------------------------

SQ:
process(Clk)
begin

    if (rising_edge(Clk)) then

        Request_SW_reduced <= '0';

        if (Request_SW = SW_SHUTDOWN_MAGIC_NUM) then

            Request_SW_reduced <= '1';

        end if;

        Request <= Request_SC_cdc or Request_SW_reduced;

        Shutdown_Release <= Request_Ack_d1 and (not Request_Ack);

        Request_Ack_d1 <= Request_Ack;

        -- If shutdown requests are being gated, latch the request here until acknowledged

        Request_Latch_int  <= (Request_Latch_int and (not Request_Ack)) or (Request and      Request_Gate_En);

        -- If shutdown requests are being not being gated, latch the request here

        if (C_ENABLE_SHUTDOWN_CLEARING = 0) then

          Shutdown_Latch_int <= Shutdown_Latch_int or (Request and (not Request_Gate_En));

        else

          Shutdown_Latch_int <= (Shutdown_Latch_int and (not Shutdown_Release)) or (Request and (not Request_Gate_En));

        end if;


        if (Rst = '0') then

            Request_Latch_int  <= '0';
            Request            <= '0';
            Shutdown_Release   <= '0';

        end if;

        Request_Latch  <= Request_Latch_int;
        Shutdown_Latch <= Shutdown_Latch_int;

    end if;

end process;

end architecture rtl;


-- (c) Copyright 2022, Advanced Micro Devices, Inc.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
------------------------------------------------------------

library ieee, unisim, xpm;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_misc.all;
    use unisim.vcomponents.all;
    use xpm.vcomponents.all;

entity shell_utils_ucc_v1_0_0_clock_throttling is
    generic (
        CLK_SLOW_DIV            : integer range 1 to 8  := 1;
        SYNTH_SIZE              : integer               := 8;
        IS_VERSAL               : boolean               := FALSE;
        SIM_DEVICE              : string                := "ULTRASCALE_PLUS";
        EXT_TOG_ENABLE          : boolean               := FALSE
    );
    port (
        Clk_In                  : in    std_logic;
        Rst_In                  : in    std_logic;
        Locked                  : in    std_logic;
        Startup_Done            : in    std_logic;

        Shutdown_Latch          : in    std_logic;  -- Input from new_latch.vhd

        Rate_Upd_Tog            : in    std_logic;  -- Rate update Toggle (asynchronous)
        Rate_In                 : in    std_logic_vector(SYNTH_SIZE-1 downto 0);

        Rst_Async               : out   std_logic;  -- Async Reset

        Ext_Tog_En              : in    std_logic; -- External Toggle HW Enable
        Ext_Tog_En_SW           : in    std_logic; -- External Toggle SW Enable
        Ext_Tog_In              : in    std_logic; -- External Toggle Input
        Ext_Tog_Out             : out   std_logic; -- External Toggle Output

        Clk_Out                 : out   std_logic;  -- Clk_In Throttled
        Clk_Out_Div             : out   std_logic;  -- (Clk_In / CLK_SLOW_DIV) Throttled (if CLK_SLOW_DIV > 1)
        Clk_Out_Cont            : out   std_logic;  -- Clk_In
        Clk_Out_Cont_Int        : out   std_logic;   -- Internal buffered Clk_In, for external toggle use only
        power_down_in           : in    std_logic;  -- Tied-off to zero if unconnected
        power_down_out          : out   std_logic
    );
end entity shell_utils_ucc_v1_0_0_clock_throttling;

architecture rtl of shell_utils_ucc_v1_0_0_clock_throttling is

-------------------------------------------------------------------------------
--
--      Constants (simple)
--
-------------------------------------------------------------------------------

constant ZERO       : std_logic_vector(0 downto 0)  := (others => '0');
constant ONE        : std_logic_vector(0 downto 0)  := (others => '1');

constant CONST_MAX  : std_logic_vector(SYNTH_SIZE-1 downto 0)   := "1" & EXT("0", SYNTH_SIZE-1);

-------------------------------------------------------------------------------
--
--      Type Definitions
--
-------------------------------------------------------------------------------

type    Int_Array   is array (integer range <>) of integer;

constant PRE_WIDTH  : Int_Array(1 to 8) := (1 to 2 => 1, 3 => 2, 4 to 5 => 3, 6 to 8 => 4);
constant SEL_WIDTH  : integer           := PRE_WIDTH(CLK_SLOW_DIV);

--tribute RLOC      : string;
--tribute HU_SET    : string;

-------------------------------------------------------------------------------
--
--      Signals
--
-------------------------------------------------------------------------------
attribute dont_touch            : string;

signal  Rst_In_cdc              : std_logic                                 := '0';
signal  Rst_In_ret              : std_logic                                 := '0';
signal  Locked_gated            : std_logic                                 := '0';
signal  Locked_cdc              : std_logic                                 := '0';
signal  Locked_ret              : std_logic                                 := '0';
signal  Startup_Done_cdc        : std_logic                                 := '0';
signal  Startup_Done_ret        : std_logic                                 := '0';
signal  power_down_in_cdc       : std_logic                                 := '0';
signal  power_down_in_ret       : std_logic                                 := '0';
signal  power_down_out_d1       : std_logic                                 := '0';

signal  Rst_Int                 : std_logic                                 := '0';

signal  Clk_Int_Cont            : std_logic                                 := '0';

signal  Rate_Upd_Tog_CDC        : std_logic                                 := '0';
signal  Last_Rate_Upd_Tog_CDC   : std_logic                                 := '0';
signal  Shutdown_Latch_CDC      : std_logic                                 := '0';
signal  Rate_Upd                : std_logic                                 := '0';
signal  Rate_int                : std_logic_vector(SYNTH_SIZE-1 downto 0)   := (others => '1');
signal  Rate_In_CDC             : std_logic_vector(SYNTH_SIZE-1 downto 0)   := (others => '1');
signal  Rate_Lim                : std_logic_vector(SYNTH_SIZE-1 downto 0)   := (others => '1');
signal  Prescale                : std_logic_vector(SEL_WIDTH-1 downto 0)    := conv_std_logic_vector(CLK_SLOW_DIV, SEL_WIDTH) - 2;
signal  Synth                   : std_logic_vector(SYNTH_SIZE-1 downto 0)   := (others => '1');

signal  Clk_Out_Div2            : std_logic                                 := '0';
signal  Clk_Out_Div4            : std_logic                                 := '0';
signal  Clk_Out_Div8            : std_logic                                 := '0';
signal  Mbufg_Clrb_SR           : std_logic_vector(1 to 8)                  := (others => '0');

signal  Ext_Tog_En_SW_cdc       : std_logic                                 := '0';
signal  Ext_Tog_En_SW_ret       : std_logic                                 := '0';
signal  Ext_Tog_Out_int         : std_logic                                 := '0';
signal  Last_Ext_Tog_In         : std_logic                                 := '0';

signal  Gate_Fast               : std_logic                                 := '0';
signal  Gate_Div                : std_logic                                 := '0';
signal  Gate_Fast_d1            : std_logic                                 := '0';
signal  Gate_Div_d1             : std_logic                                 := '0';

attribute dont_touch  of Gate_Fast    : signal is "true";
attribute dont_touch  of Gate_Div     : signal is "true";
attribute dont_touch  of Gate_Fast_d1 : signal is "true";
attribute dont_touch  of Gate_Div_d1  : signal is "true";

begin

Locked_gated <= Locked and not power_down_in;
-------------------------------------------------------------------------------
--
--      CDC the Rate_Upd and Ext_Tog_En_SW onto the local domain
--
-------------------------------------------------------------------------------

UP_CDC:
xpm_cdc_single
    generic map (
        DEST_SYNC_FF    => 4,
        SRC_INPUT_REG   => 0
    )
    port map (
        src_clk     => ZERO(0),
        src_in      => Rate_Upd_Tog,

        dest_clk    => Clk_Int_Cont,
        dest_out    => Rate_Upd_Tog_CDC
    );

RATE_CDC:
xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF    => 2,
        SRC_INPUT_REG   => 0,
        SIM_ASSERT_CHK  => 0,
        WIDTH           => SYNTH_SIZE
    )
    port map (
        src_clk     => ZERO(0),
        src_in      => Rate_In,

        dest_clk    => Clk_Int_Cont,
        dest_out    => Rate_In_CDC
    );

LA_CDC:
xpm_cdc_single
    generic map (
        DEST_SYNC_FF    => 4,
        SRC_INPUT_REG   => 0
    )
    port map (
        src_clk     => ZERO(0),
        src_in      => Shutdown_Latch,

        dest_clk    => Clk_Int_Cont,
        dest_out    => Shutdown_Latch_CDC
    );

ETG: if (EXT_TOG_ENABLE) generate

    ETSE_CDC:
    xpm_cdc_single
        generic map (
            DEST_SYNC_FF    => 4,
            SRC_INPUT_REG   => 0
        )
        port map (
            src_clk     => ZERO(0),
            src_in      => Ext_Tog_En_SW,

            dest_clk    => Clk_Int_Cont,
            dest_out    => Ext_Tog_En_SW_cdc
        );

end generate ETG;

-------------------------------------------------------------------------------
--
--      Retime reset control signals on the internal clock
--
-------------------------------------------------------------------------------

    RST_CDC : xpm_cdc_async_rst
    generic map (
        DEST_SYNC_FF    => 4,
        INIT_SYNC_FF    => 1,
        RST_ACTIVE_HIGH => 0
    )
    port map (
        dest_arst => Rst_In_cdc,
        dest_clk  => Clk_Int_Cont,
        src_arst  => Rst_In
    );

    LCK_CDC : xpm_cdc_async_rst
    generic map (
        DEST_SYNC_FF    => 4,
        INIT_SYNC_FF    => 1,
        RST_ACTIVE_HIGH => 0
    )
    port map (
        dest_arst => Locked_cdc,
        dest_clk  => Clk_Int_Cont,
        src_arst  => Locked_gated
    );

    SRT_CDC : xpm_cdc_async_rst
    generic map (
        DEST_SYNC_FF    => 4,
        INIT_SYNC_FF    => 1,
        RST_ACTIVE_HIGH => 0
    )
    port map (
        dest_arst => Startup_Done_cdc,
        dest_clk  => Clk_Int_Cont,
        src_arst  => Startup_Done
    );

    PD_CDC : xpm_cdc_async_rst
    generic map (
        DEST_SYNC_FF    => 4,
        INIT_SYNC_FF    => 1,
        RST_ACTIVE_HIGH => 0
    )
    port map (
        dest_arst => power_down_in_cdc,
        dest_clk  => Clk_Int_Cont,
        src_arst  => power_down_in
    );

-------------------------------------------------------------------------------
--
--      Instantiate the Internal continuous Clock buffer
--
-------------------------------------------------------------------------------

ICCLK:
BUFG
    port map (
        I   => Clk_In,
        O   => Clk_Int_Cont
    );

-- Output the internal continuous clock when the external toggle interface is enabled
with EXT_TOG_ENABLE select
    Clk_Out_Cont_Int <= Clk_Int_Cont when TRUE,
                        '0'          when others;

-------------------------------------------------------------------------------
--
--      Instantiate the External continuous Clock buffer
--
-------------------------------------------------------------------------------

ECCLK:
BUFGCE
   generic map (
      CE_TYPE        => "HARDSYNC",
      SIM_DEVICE     => SIM_DEVICE
   )
    port map (
        I   => Clk_In,
        CE  => Startup_Done_cdc,

        O   => Clk_Out_Cont
    );

-------------------------------------------------------------------------------
--
--      Instantiate the Clk_Out Gated Clock Buffer
--
-------------------------------------------------------------------------------
VGC:
if (IS_VERSAL and (CLK_SLOW_DIV = 1)) generate

-- For Versal, instantiate a BUFGCE for the gapped clock when the divided clock is not enabled
-- Use the hard synchronizer on the CE path to ease timing

FCLK:
BUFGCE
    generic map (
        CE_TYPE     => "HARDSYNC",
        SIM_DEVICE  => SIM_DEVICE
    )
    port map (
        I   => Clk_In,
        CE  => Gate_Fast,

        O   => Clk_Out
    );

end generate VGC;

GC:
if (not IS_VERSAL) generate

-- For VUP, instantiate a BUFGCE and use synchronous timing on the CE path (default)

FCLK:
BUFGCE
    port map (
        I   => Clk_In,
        CE  => Gate_Fast_d1,

        O   => Clk_Out
    );

end generate GC;

-------------------------------------------------------------------------------
--
--      Instantiate the Slow edge aligned buffer if required
--
-------------------------------------------------------------------------------

VGD:
if ((CLK_SLOW_DIV > 1) and IS_VERSAL) generate

  -- For Versal, when the divided clock is enabled then use a MBUFGCE to generate both gapped and divided gapped clocks
  -- Use the Hard synchronizer to ease timing on the CE path

SCLK:
MBUFGCE
    generic map (
        CE_TYPE     => "HARDSYNC",
        MODE        => "PERFORMANCE",
        SIM_DEVICE  => SIM_DEVICE
    )
    port map (
        I         => Clk_In,
        CLRB_LEAF => Mbufg_Clrb_SR(1),
        CE        => Gate_Div,

        O1        => Clk_Out,
        O2        => Clk_Out_Div2,
        O3        => Clk_Out_Div4,
        O4        => Clk_Out_Div8
    );

    -- Assign the selected divided clock to the output
    with CLK_SLOW_DIV select
        Clk_Out_Div <=  Clk_Out_Div2 when 2,
                        Clk_Out_Div4 when 4,
                        Clk_Out_Div8 when others;

end generate VGD;

GD:
if ((CLK_SLOW_DIV > 1) and (not IS_VERSAL)) generate

SCLK:
BUFGCE_DIV
    generic map (
        BUFGCE_DIVIDE   => CLK_SLOW_DIV
    )
    port map (
        I   => Clk_In,
        CLR => ZERO(0),
        CE  => Gate_Div_d1,

        O   => Clk_Out_Div
    );

end generate GD;

-------------------------------------------------------------------------------
--
--      Controller Logic
--
-------------------------------------------------------------------------------

SQ:
process(Clk_Int_Cont)
begin

    if (rising_edge(Clk_Int_Cont)) then

       -- Flop the output of the cdcs to allow replication

        Rst_In_ret       <= Rst_In_cdc;
        Locked_ret       <= Locked_cdc;
        Startup_Done_ret <= Startup_Done_cdc;
        power_down_in_ret <= power_down_in_cdc;

        -- Generate reset

        Rst_Int <= Rst_In_ret and Locked_ret and Startup_Done_ret;

        -- Shift a '1' through the MBUFGCE clear delay SR, use to extend the CE assertion past CLRB_LEAF in order to meet the 10ns delay requirement
        if (IS_VERSAL) then

            Mbufg_Clrb_SR <= '1' & Mbufg_Clrb_SR(1 to Mbufg_Clrb_SR'HIGH-1);

        else

            Mbufg_Clrb_SR <= (others => '1');

        end if;

        -- Wait for a change of state of the Rate_Upd_Tog input, and reload the Rate signal

        Last_Rate_Upd_Tog_CDC   <= Rate_Upd_Tog_CDC;

        Rate_Upd    <= Rate_Upd_Tog_CDC xor Last_Rate_Upd_Tog_CDC;

        if (Rate_Upd = '1') then

            Rate_int <= Rate_In_CDC;

        end if;

        -- If Throttling is enabled and a clock shutdown has occurred, limit the rate to no more than 25%

        if ((Shutdown_Latch_CDC = '1') and (or_reduce(Rate_int(SYNTH_SIZE-1 downto SYNTH_SIZE-3)) = '1')) then

            Rate_Lim    <= "001" & EXT("0", Rate_Lim'LENGTH - 3);

        else

            Rate_Lim    <= Rate_int;

        end if;

        if (Prescale(Prescale'HIGH) = '1') then

            Prescale    <= conv_std_logic_vector(CLK_SLOW_DIV, Prescale'LENGTH) - 2;

            -- Implement N/M Synthesiser
            -- Treat all values >= 128 as 100%

            if (Rate_int(Rate_Lim'HIGH) = '1') then

                Synth   <= ("0" & Synth(Synth'HIGH-1 downto 0)) + CONST_MAX;

            else

                Synth   <= ("0" & Synth(Synth'HIGH-1 downto 0)) + Rate_Lim;

            end if;

            if (EXT_TOG_ENABLE) then

                Ext_Tog_En_SW_ret   <= Ext_Tog_En_SW_cdc;
                Last_Ext_Tog_In     <= Ext_Tog_In;

                if (Ext_Tog_En = '1' and Ext_Tog_En_SW_ret = '1') then

                    Ext_Tog_Out_int     <= Synth(Synth'HIGH) xor Ext_Tog_Out_int;
                    Gate_Fast           <= Ext_Tog_In xor Last_Ext_Tog_In;
                    Gate_Div            <= (Ext_Tog_In xor Last_Ext_Tog_In) and Mbufg_Clrb_SR(Mbufg_Clrb_SR'HIGH);

                else

                    Ext_Tog_Out_int     <= '0';
                    Gate_Fast           <= Synth(Synth'HIGH);
                    Gate_Div            <= Synth(Synth'HIGH) and Mbufg_Clrb_SR(Mbufg_Clrb_SR'HIGH);

                end if;

            else

                Ext_Tog_Out_int     <= '0';
                Gate_Fast           <= Synth(Synth'HIGH);
                Gate_Div            <= Synth(Synth'HIGH) and Mbufg_Clrb_SR(Mbufg_Clrb_SR'HIGH);

            end if;

        else

            Prescale    <= Prescale - 1;

        end if;

        if (Rst_Int = '0') then

            Prescale        <= conv_std_logic_vector(CLK_SLOW_DIV, Prescale'LENGTH) - 2;
            Rate_int        <= (others => '1'); -- Default to 100 %
            Synth           <= (others => '1');

            Gate_Fast       <= '0';
            Gate_Div        <= '0';

            power_down_out_d1  <= power_down_in_ret;

            if (IS_VERSAL) then

                Mbufg_Clrb_SR   <= (others => '0');

            end if;

        end if;

        if (not IS_VERSAL) then

            -- Flop the gate signals to assist timing closure in VUP

            Gate_Fast_d1      <= Gate_Fast;
            Gate_Div_d1       <= Gate_Div;

        end if;

    end if;

end process;

Rst_Async <= Rst_Int;

Ext_Tog_Out <= Ext_Tog_Out_int;

power_down_out <= power_down_out_d1 AND power_down_in;

end architecture rtl;


-- (c) Copyright 2022, Advanced Micro Devices, Inc.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_misc.all;

entity shell_utils_ucc_v1_0_0_throttling_avg is
    generic (
        SAMPLE_WIDTH       : integer := 8;
        SAMPLE_SAT_VAL     : integer := 128;
        AVE_NUM_SAMPLES    : integer := 50;
        AVE_WIDTH          : integer := 14;
        RST_CNT_BITS       : integer := 6
    );
    port (
        Clk             : in    std_logic;
        Rst             : in    std_logic;

        Rate_Upd_Tog    : in    std_logic;  -- Rate update Toggle
        Rate            : in    std_logic_vector(SAMPLE_WIDTH-1 downto 0);

        Rate_Avg        : out   std_logic_vector(AVE_WIDTH-1 downto 0)
    );
end entity shell_utils_ucc_v1_0_0_throttling_avg;

architecture rtl of shell_utils_ucc_v1_0_0_throttling_avg is

-------------------------------------------------------------------------------
--
--      Constants (simple)
--
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--
--      Type Definitions
--
-------------------------------------------------------------------------------

type Pipe_Type is
    record
        Valid           : std_logic;
        Flush           : std_logic;
        New_Sample      : std_logic_vector(SAMPLE_WIDTH-1 downto 0);
        Exprd_Sample    : std_logic_vector(SAMPLE_WIDTH-1 downto 0);
        Avg_Calc        : std_logic_vector(AVE_WIDTH-1 downto 0);
    end record;

constant RST_PIPE_TYPE : Pipe_Type := (
    '0',                            -- std_logic;
    '0',                            -- std_logic;
    (others => '0'),                -- std_logic_vector(SAMPLE_WIDTH-1 downto 0);
    (others => '0'),                -- std_logic_vector(SAMPLE_WIDTH-1 downto 0);
    (others => '0'));               -- std_logic_vector(AVE_WIDTH-1 downto 0);

type Pipe_Array_Type is array (integer range <>) of Pipe_Type;

type Sample_Array_Type is array (integer range <>) of std_logic_vector(SAMPLE_WIDTH-1 downto 0);

-------------------------------------------------------------------------------
--
--      Signals
--
-------------------------------------------------------------------------------

signal  Pipe         : Pipe_Array_Type(0 to 3)                   := (others => RST_PIPE_TYPE);
signal  Sample_Pipe  : Sample_Array_Type(0 to AVE_NUM_SAMPLES-1) := (others => (others => '0'));

signal  Rate_Upd_Tog_d1 : std_logic                                 := '0';
signal  Avg             : std_logic_vector(AVE_WIDTH-1 downto 0)    := (others => '0');
signal  Rst_Count       : std_logic_vector(RST_CNT_BITS downto 0)   := (others => '0');

begin

SQ:
process(Clk)
begin

    if (rising_edge(Clk)) then

        if (Rst = '0') then

            Rst_Count <= (others => '1');

        elsif (Rst_Count(Rst_Count'HIGH) = '1') then

            Rst_Count <= Rst_Count - 1;

        end if;

        Rate_Upd_Tog_d1 <= Rate_Upd_Tog;

        Pipe(0).Flush    <= Rst_Count(Rst_Count'HIGH);

        Pipe(0).Valid    <= (Rate_Upd_Tog xor Rate_Upd_Tog_d1) and not Rst_Count(Rst_Count'HIGH);

        if (Rate(Rate'HIGH) = '1') then

            Pipe(0).New_Sample   <= conv_std_logic_vector(SAMPLE_SAT_VAL, Pipe(0).New_Sample'LENGTH);

        else

            Pipe(0).New_Sample   <= Rate;

        end if;

        Pipe(1 to Pipe'HIGH)    <= Pipe(0 to Pipe'HIGH-1);

        -----------------------------------------------------------------------
        --  Stage 1 :
        -----------------------------------------------------------------------

        Pipe(1).New_Sample <= Pipe(1).New_Sample;

        if (Pipe(0).Flush = '1') then

            Pipe(1).New_Sample <= (others => '0');

        elsif (Pipe(0).Valid = '1') then

            Pipe(1).New_Sample <= SAMPLE_SAT_VAL - Pipe(0).New_Sample;

        end if;

        -----------------------------------------------------------------------
        --  Stage 2 :
        -----------------------------------------------------------------------

        Pipe(2).Avg_Calc     <= Pipe(2).Avg_Calc;
        Pipe(2).Exprd_Sample <= Pipe(2).Exprd_Sample;

        if (Pipe(1).Flush = '1') then

            Pipe(2).Avg_Calc     <= (others => '0');
            Pipe(2).Exprd_Sample <= (others => '0');

        elsif (Pipe(1).Valid = '1') then

            Pipe(2).Avg_Calc     <= Avg;
            Pipe(2).Exprd_Sample <= Sample_Pipe(Sample_Pipe'HIGH);

        end if;


        if ((Pipe(1).Valid = '1') or (Pipe(1).Flush = '1')) then

            Sample_Pipe(0)                     <= Pipe(1).New_Sample;
            Sample_Pipe(1 to Sample_Pipe'HIGH) <= Sample_Pipe(0 to Sample_Pipe'HIGH-1);

        end if;

        -----------------------------------------------------------------------
        --  Stage 3 :
        -----------------------------------------------------------------------

        Pipe(3).Avg_Calc <= Pipe(2).Avg_Calc - Pipe(2).Exprd_Sample;

        -----------------------------------------------------------------------
        --  Stage 4 :
        -----------------------------------------------------------------------

        if (Pipe(3).Flush = '1') then

            Avg <= (others => '0');

        elsif (Pipe(3).Valid = '1') then

            Avg <= Pipe(3).Avg_Calc + Pipe(3).New_Sample;

        end if;

    end if;

end process;

Rate_Avg <= Avg;

end architecture rtl;


