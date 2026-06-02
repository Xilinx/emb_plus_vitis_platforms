{
  "spec_file_version": 4,
  "info": {
    "arch_data_version": 100,
    "device_name": "ve2302",
    "settings_file": "default_settings",
    "settings_suffix": "ps-pmc",
    "format": "deep",
    "validated": true
  },
  "flags": {"debugger_access": true, "enable_protection": true, "write_subsystems": true},
  "modules": {
    "iso_spec": {
      "module_rules": [
        {"name": "debugger_access", "flag": "bool", "desc": "Enable debugger access, see Root Access page."},
        {"name": "enable_protection", "flag": "bool", "desc": "Configure protection units"},
        {"name": "write_subsystems", "flag": "bool", "desc": "Write subsystems. Protection units include subsystem protection regardless of this setting"}
      ]
    },
    "isoutil_gui": {
      "module_rules": [
        {"name": "isospecFile", "flag": "string", "display": "Save spec file name", "desc": "Isolation spec file name for Save"},
        {"name": "writeShallow", "flag": "bool", "hide": true, "display": "write shallow", "desc": "On save, write a shallow spec (only user settings), and don't include device data"},
        {"name": "cdoFile", "flag": "string", "display": "Output CDO file name", "desc": "File name for Write CDO"}
      ]
    },
    "domain": {
      "module_rules": [
        {"name": "ignore", "flag": "bool", "desc": "Ignore or disable this domain"},
        {"name": "os_type", "flag": "string", "display": "os,type", "desc": "Specifies the OS for a device tree. Format: OS[,type[,version]]", "choices": [
            {"choice": "linux"},
            {"choice": "linux,yocto"},
            {"choice": "linux,ubuntu"},
            {"choice": "baremetal"},
            {"choice": "freertos"},
            {"choice": "zephyr"},
            {"choice": "xen"},
            {"choice": "custom"}
          ]
        }
      ]
    },
    "access": {
      "access_rules": [
        {"name": "ignore", "flag": "bool", "desc": "Ignore or disable this access"},
        {"name": "tool_managed", "flag": "bool", "desc": "Tool managed access"}
      ]
    },
    "base_protection": {},
    "subsystem": {
      "constants": {"dynamic_nodeid_base": "0x18900000", "marker": "SUBSYSTEM_DEFINITION/SUBSYSTEMS", "max_dynamic_nodeids": 64, "max_ss_ids": 16, "reserved_ss_ids": 6, "ss_id_base": "0x1c000000"},
      "access_rules": [
        {"name": "secure", "flag": "bool", "hide": true, "desc": "declare secure flag for the allow_secure rule. Flag may be set from the xppu/xmpu"},
        {"flag": "radio_group", "display": "Sharing", "children": [
            {"flag": "radio_default", "display": "not shared", "desc": "not shared"},
            {"name": "shared", "flag": "bool", "display": "concurrent shared", "desc": "allow concurrent sharing"},
            {"name": "timeshare", "flag": "bool", "display": "time shared", "desc": "allow time sharing"}
          ]
        },
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "allow_secure", "flag": "bool", "read_only": true, "hide": true, "default": "secure", "output": 0, "lsb": 2, "desc": "Device may be requested as secure. Set from the access 'secure' flag."},
                {"name": "concurrent_shared", "cond": "shared && !timeshare", "output": 1, "lsb": 0},
                {"name": "non_shared", "cond": "!shared && !timeshare", "output": 2, "lsb": 0},
                {"name": "timeshare", "cond": "timeshare", "output": 3, "lsb": 0, "desc": "Device or memory is time shared between subsystems"},
                {"name": "requested", "cond": "requested", "output": 1, "lsb": 6}
              ]
            },
            {"output": 0, "desc": "aperture"},
            {"name": "requested", "flag": "bool", "desc": "The device is ready and available (brought out of reset and clock started) at subsystem start. An IPI call to PLM to request the device is not needed before using the device", "choices": [
                {"choice": true, "children": [
                    {"name": "requested_full_access", "flag": "bool", "output": 1, "lsb": 0, "display": "full_access", "desc": "Start in full power state (not suspended)"},
                    {"name": "requested_preserve_context", "flag": "bool", "output": 1, "lsb": 1, "display": "preserve_context", "desc": "Preserve memory contents when suspended"},
                    {"name": "requested_emit_wakeup", "flag": "bool", "output": 1, "lsb": 2, "display": "emit_wakeup", "desc": "Emit wake interrupts when suspended"}
                  ]
                }
              ]
            },
            {"name": "qos", "flag": "int", "flag_min": 0, "flag_max": 65535, "default": 100, "output": "qos", "desc": "Quality of Service, defaults is 100"}
          ]
        }
      ],
      "module_rules": [
        {"name": "ignore", "flag": "bool", "desc": "Ignore or disable this subsystem"}
      ]
    },
    "subsystem.apu": {
      "access_rules": [
        {"name": "secure", "flag": "bool", "desc": "CPU issues secure transactions"},
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "allow_secure", "output": 0, "lsb": 2, "desc": "0 == Device may be requested as secure"},
                {"name": "non_shared", "output": 2, "lsb": 0},
                {"name": "requested", "output": 1, "lsb": 6}
              ]
            },
            {"output": 0, "desc": "aperture"},
            {"name": "requested", "children": [
                {"name": "requested_full_access", "output": 1, "lsb": 0, "display": "full_access"},
                {"name": "requested_secure", "cond": "secure", "output": 1, "lsb": 4, "display": "secure"}
              ]
            },
            {"name": "qos", "output": "0x64"}
          ]
        }
      ]
    },
    "subsystem.rpu": {
      "access_rules": [
        {"name": "secure", "flag": "bool", "desc": "CPU issues secure transactions"},
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "allow_secure", "output": 0, "lsb": 2, "desc": "0 == Device may be requested as secure"},
                {"name": "non_shared", "output": 2, "lsb": 0},
                {"name": "requested", "output": 1, "lsb": 6}
              ]
            },
            {"output": 0, "desc": "aperture"},
            {"name": "requested", "children": [
                {"name": "requested_full_access", "output": 1, "lsb": 0, "display": "full_access"},
                {"name": "requested_secure", "cond": "secure", "output": 1, "lsb": 4, "display": "secure"},
                {"name": "coherent", "flag": "bool", "output": 1, "lsb": 5, "display": "coherent", "desc": "Routed through Cache Coherent Interconnect and SMMU in FPD"},
                {"name": "virtualized", "cond": "coherent", "output": 1, "lsb": 6}
              ]
            },
            {"name": "qos", "output": "0x64"}
          ]
        }
      ]
    },
    "subsystem.manager": {
      "access_rules": [
        {"name": "secure", "flag": "bool", "hide": true, "desc": "declare secure flag for the allow_secure rule. Flag may be set from the xppu/xmpu"},
        {"name": "exists_req_virtual", "flag": "bool", "hide": true, "desc": "from code, set if any destination is requested_virtual"},
        {"flag": "radio_group", "display": "Sharing", "children": [
            {"flag": "radio_default", "display": "not shared", "desc": "not shared"},
            {"name": "shared", "flag": "bool", "display": "concurrent shared", "desc": "allow concurrent sharing"},
            {"name": "timeshare", "flag": "bool", "display": "time shared", "desc": "allow time sharing"}
          ]
        },
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "allow_secure", "flag": "bool", "read_only": true, "default": "secure", "output": 0, "lsb": 2, "desc": "Allow requested as secure, so the manager side will issue secure transactions. Set from the access 'secure' flag."},
                {"name": "concurrent_shared", "cond": "shared && !timeshare", "output": 1, "lsb": 0},
                {"name": "non_shared", "cond": "!shared && !timeshare", "output": 2, "lsb": 0},
                {"name": "timeshare", "cond": "timeshare", "output": 3, "lsb": 0, "desc": "Device or memory is time shared between subsystems"},
                {"name": "requested", "cond": "requested", "output": 1, "lsb": 6}
              ]
            },
            {"output": 0, "desc": "aperture"},
            {"name": "requested", "flag": "bool", "desc": "The device is ready and available (brought out of reset and clock started) at subsystem start. An IPI call to PLM to request the device is not needed before using the device", "choices": [
                {"choice": true, "children": [
                    {"name": "requested_full_access", "flag": "bool", "output": 1, "lsb": 0, "display": "full_access", "desc": "Start in full power state (not suspended)"},
                    {"name": "requested_preserve_context", "flag": "bool", "output": 1, "lsb": 1, "display": "preserve_context", "desc": "Preserve memory contents when suspended"},
                    {"name": "requested_emit_wakeup", "flag": "bool", "output": 1, "lsb": 2, "display": "emit_wakeup", "desc": "Emit wake interrupts when suspended"},
                    {"name": "requested_secure", "flag": "bool", "output": 1, "lsb": 4, "display": "secure", "desc": "Manager side (DMA) issues secure transactions",
                      "checks": [
                        {"type": "error", "pre": true, "cond": "!requested_secure || secure", "message": "requested_secure can only be set if the secure flag is set"}
                      ]
                    },
                    {"name": "requested_coherent", "flag": "bool", "output": 1, "lsb": 5, "display": "coherent", "desc": "Manager side (DMA) transactions are routed via cache coherent interconnect",
                      "checks": [
                        {"type": "warn", "pre": true, "cond": "!(requested_coherent && exists_req_virtual && !requested_virtualized)", "message": "requested_virtualized should be set if coherent and another peripheral is requested_virtualized"}
                      ]
                    },
                    {"name": "requested_virtualized", "flag": "bool", "output": 1, "lsb": 6, "display": "virtualized", "desc": "Manager side (DMA) transactions routed via SMMU"},
                    {"name": "implied_req_virtualized", "cond": "requested_coherent && exists_req_virtual && !requested_virtualized", "output": 1, "lsb": 6, "desc": "If any LPD peripheral is requested_virtual, then all coherent LPD peripherals must be virt"}
                  ]
                }
              ]
            },
            {"name": "qos", "flag": "int", "flag_min": 0, "flag_max": 65535, "default": 100, "output": "qos", "desc": "Quality of Service, defaults is 100"}
          ]
        }
      ]
    },
    "subsystem.healthy_boot_monitor": {
      "access_rules": [
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"flag": "radio_group", "display": "Usage", "children": [
                {"flag": "radio_default", "display": "Used during Runtime", "desc": "Used for subsystem restart recovery"},
                {"name": "requested", "flag": "bool", "output": 1, "lsb": 6, "display": "Used during Boot (requested)", "desc": "Used for subsystem boot monitoring"}
              ]
            },
            {"name": "aperture", "output": 0},
            {"name": "requested_as", "children": [
                {"name": "full_access", "output": "requested", "lsb": 0}
              ]
            },
            {"name": "timeout", "flag": "int", "flag_min": 0, "flag_max": 3600000, "default": 1000, "output": "timeout", "desc": "timeout in ms, default is 1000ms, max is 1 hour"}
          ]
        }
      ],
      "module_rules": [
        {"name": "add_node", "action": "pm_add_node", "desc": "using module rules for pm_add_node in subsystem", "children": [
            {"output": "node_id"},
            {"name": "PM_POWER_PMC", "output": "0x4208001"},
            {"output": 0},
            {"output": 0},
            {"output": 0}
          ]
        }
      ]
    },
    "subsystem.ipi": {
      "access_rules": [
        {"name": "secure", "flag": "bool", "hide": true, "desc": "declare secure flag for the allow_secure rule. Flag may be set from the xppu/xmpu"},
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "allow_secure", "flag": "bool", "read_only": true, "default": "secure", "output": 0, "lsb": 2, "desc": "Device may be requested as secure. Set from the access 'secure' flag."},
                {"name": "non_shared", "output": 2, "lsb": 0},
                {"name": "requested", "cond": "requested", "output": 1, "lsb": 6}
              ]
            },
            {"output": 0, "desc": "aperture"},
            {"name": "requested", "flag": "bool", "desc": "The device is ready and available with full access (brought out of reset and clock started) at subsystem start. An IPI call to PLM to request the device is not needed before using the device", "choices": [
                {"choice": true, "children": [
                    {"name": "requested_full_access", "output": 1, "lsb": 0}
                  ]
                }
              ]
            },
            {"name": "qos", "output": "0x64"}
          ]
        }
      ]
    },
    "subsystem.reset": {
      "access_rules": [
        {"name": "secure", "flag": "bool", "desc": "allow access only by secure managers"},
        {"flag": "radio_group", "display": "Sharing", "children": [
            {"flag": "radio_default", "display": "not shared", "desc": "not shared"},
            {"name": "shared", "flag": "bool", "display": "concurrent shared", "desc": "allow concurrent sharing"}
          ]
        },
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "write", "cond": "!secure", "output": 1, "lsb": 0},
                {"name": "secure_write", "output": 1, "lsb": 16}
              ]
            }
          ]
        }
      ]
    },
    "subsystem.general_storage": {
      "access_rules": [
        {"name": "read_only", "flag": "bool", "desc": "allow read access"},
        {"name": "secure", "flag": "bool", "desc": "allow access only by secure managers"},
        {"flag": "radio_group", "display": "Sharing", "children": [
            {"flag": "radio_default", "display": "not shared", "desc": "not shared"},
            {"name": "shared", "flag": "bool", "display": "concurrent shared", "desc": "allow concurrent sharing"}
          ]
        },
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"name": "read", "cond": "!secure", "output": 1, "lsb": 0},
                {"name": "write", "cond": "!read_only && !secure", "output": 1, "lsb": 1},
                {"name": "secure_read", "output": 1, "lsb": 16},
                {"name": "secure_write", "cond": "!read_only", "output": 1, "lsb": 17}
              ]
            }
          ]
        }
      ],
      "module_rules": [
        {"name": "add_node", "action": "pm_add_node", "desc": "using module rules for pm_add_node in subsystem", "children": [
            {"output": "node_id"},
            {"name": "PM_POWER_PMC", "output": "0x4208001"},
            {"output": 0},
            {"output": 0},
            {"output": 0}
          ]
        }
      ]
    },
    "subsystem.ss_permissions": {
      "display": "Subsystem Permissions",
      "access_rules": [
        {"name": "add_requirement", "action": "pm_req", "children": [
            {"output": "subsystem_id"},
            {"output": "node_id"},
            {"name": "flags", "children": [
                {"flag": "group", "display": "Non-Secure", "children": [
                    {"name": "wake", "flag": "bool", "output": 1, "lsb": 0, "desc": "Wake a subsystem"},
                    {"name": "powerdown", "flag": "bool", "output": 1, "lsb": 1, "desc": "Power down a subsystem"},
                    {"name": "suspend", "flag": "bool", "hide": true, "output": 1, "lsb": 2, "desc": "Suspend a subsystem"}
                  ]
                },
                {"flag": "group", "display": "Secure", "children": [
                    {"name": "secure_wake", "flag": "bool", "output": 1, "lsb": 16, "desc": "Wake a subsystem"},
                    {"name": "secure_powerdown", "flag": "bool", "output": 1, "lsb": 17, "desc": "Power down a subsystem"},
                    {"name": "secure_suspend", "flag": "bool", "hide": true, "output": 1, "lsb": 18, "desc": "Suspend a subsystem"}
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    "xppu": {
      "access_rules": [
        {"flag": "radio_group", "display": "Access Mode", "children": [
            {"flag": "radio_default", "display": "read/write", "desc": "read and write access"},
            {"name": "read_only", "flag": "bool", "display": "read only", "desc": "allow read access"}
          ]
        },
        {"flag": "radio_group", "display": "Secure Mode", "children": [
            {"flag": "radio_default", "display": "non-secure", "desc": "accessible by secure and non-secure managers"},
            {"name": "secure", "flag": "bool", "desc": "accessible by secure managers only"}
          ]
        },
        {"flag": "group", "display": "Advanced", "children": [
            {"name": "no_root_access", "flag": "bool", "display": "no root access", "desc": "Don't include XPPU root access permissions"}
          ]
        }
      ],
      "module_rules": [
        {"name": "enable", "flag": "bool", "desc": "Configure the XPPU"},
        {"name": "disable_inv_apb", "flag": "bool", "hide": true, "desc": "Architecture needs INV_APB interrupt disabled (set via arch constants)"},
        {"name": "interrupt_enable", "flag": "bool", "output": "0xff", "action": "write_if_set", "offset": "0x18", "desc": "Enable interrupts on violation"},
        {"name": "ids_inv_apb", "output": 1, "action_enable": "disable_inv_apb", "action": "write", "offset": "0x1c", "desc": "Disable INV_APB interrupt to prevent EAM on shared APB bridge"},
        {"name": "ctrl", "action": "write", "children": [
            {"name": "enable", "output": 7, "lsb": 0, "desc": "enable xppu & parity"},
            {"name": "hide_en", "flag": "bool", "output": 1, "lsb": 3, "desc": "Hide error response"}
          ]
        },
        {"name": "lock", "flag": "bool", "output": 1, "action": "write_if_set", "offset": "0x20", "desc": "Prevent changes after enable, until power-on-reset"}
      ]
    },
    "xmpu": {
      "constants": {"hasGap": true, "region_offset": "0x100", "regions": 16},
      "access_rules": [
        {"flag": "radio_group", "display": "Access Mode", "children": [
            {"flag": "radio_default", "display": "read/write", "desc": "read and write access"},
            {"name": "read_only", "flag": "bool", "display": "read only", "desc": "allow read access"},
            {"name": "write_only", "flag": "bool", "display": "write only", "desc": "allow write access"},
            {"name": "block", "flag": "bool", "desc": "no access"}
          ]
        },
        {"name": "Rnn_CONFIG", "action": "write", "offset": "0x14", "children": [
            {"flag": "radio_group", "display": "Secure Mode", "children": [
                {"flag": "radio_default", "display": "non-secure", "desc": "accessible by secure and non-secure managers"},
                {"name": "secure", "flag": "bool", "desc": "accessible by secure managers only"},
                {"name": "non-secure", "cond": "secure", "output": 0, "lsb": 3, "desc": "to print non-secure[3] = 0 due to secure = 1"},
                {"name": "strict_non_secure", "flag": "bool", "output": 1, "lsb": 4, "desc": "accessible by non-secure managers only"}
              ]
            },
            {"name": "WrAllowed", "cond": "!block && !read_only", "output": 1, "lsb": 2},
            {"name": "RdAllowed", "cond": "!block && !write_only", "output": 1, "lsb": 1},
            {"name": "Enable", "output": 1, "lsb": 0}
          ]
        }
      ],
      "module_rules": [
        {"name": "enable", "flag": "bool", "desc": "Configure the XMPU"},
        {"name": "interrupt_enable", "flag": "bool", "output": "0xff", "action": "write_if_set", "offset": "0x18", "desc": "Enable interrupts on violation"},
        {"name": "ctrl", "action": "mask_write", "mask": "0xf", "children": [
            {"name": "default_read", "flag": "bool", "output": 1, "lsb": 0, "desc": "Allow reads from addresses that are not in any XMPU region"},
            {"name": "default_write", "flag": "bool", "output": 1, "lsb": 1, "desc": "Allow writes to addresses that are not in any XMPU region"},
            {"name": "hide_en", "flag": "bool", "output": 1, "lsb": 2, "desc": "Hide error response"}
          ]
        },
        {"name": "lock", "flag": "bool", "output": 1, "action": "write_if_set", "offset": "0x20", "desc": "Prevent changes after enable, until power-on-reset"}
      ]
    },
    "ddr4_xmpu": {
      "constants": {"hasGap": false, "region_offset": "0x100", "regions": 16},
      "access_rules": [
        {"flag": "radio_group", "display": "Access Mode", "children": [
            {"flag": "radio_default", "display": "read/write", "desc": "read and write access"},
            {"name": "read_only", "flag": "bool", "display": "read only", "desc": "allow read access"},
            {"name": "write_only", "flag": "bool", "display": "write only", "desc": "allow write access"},
            {"name": "block", "flag": "bool", "desc": "no access"}
          ]
        },
        {"name": "Rnn_CONFIG", "action": "write", "offset": "0x14", "children": [
            {"flag": "radio_group", "display": "Secure Mode", "children": [
                {"flag": "radio_default", "display": "non-secure", "desc": "accessible by secure and non-secure managers"},
                {"name": "secure", "flag": "bool", "desc": "accessible by secure managers only"},
                {"name": "non-secure", "cond": "secure", "output": 0, "lsb": 3, "desc": "to print non-secure[3] = 0 due to secure = 1"},
                {"name": "strict_non_secure", "flag": "bool", "output": 1, "lsb": 4, "desc": "accessible by non-secure managers only"}
              ]
            },
            {"name": "WrAllowed", "cond": "!block && !read_only", "output": 1, "lsb": 2},
            {"name": "RdAllowed", "cond": "!block && !write_only", "output": 1, "lsb": 1},
            {"name": "Enable", "output": 1, "lsb": 0}
          ]
        }
      ],
      "module_rules": [
        {"name": "enable", "flag": "bool", "desc": "Configure the XMPU"},
        {"name": "ctrl", "action": "mask_write", "mask": "0xf", "children": [
            {"name": "default_read", "flag": "bool", "output": 1, "lsb": 0, "desc": "Allow reads from addresses that are not in any XMPU region"},
            {"name": "default_write", "flag": "bool", "output": 1, "lsb": 1, "desc": "Allow writes to addresses that are not in any XMPU region"},
            {"name": "hide_en", "flag": "bool", "output": 1, "lsb": 2, "desc": "Hide error response"}
          ]
        },
        {"name": "lock", "flag": "bool", "output": 1, "action": "write_if_set", "offset": "0x20", "desc": "Prevent changes after enable, until power-on-reset"}
      ]
    },
    "hbm_xmpu": {
      "copy": "ddr4_xmpu",
      "constants": {"hasGap": false, "region_offset": "0x4", "regions": 2}
    },
    "ipi": {
      "display": "IPI Channels",
      "group": "Inter-Processor Interrupts",
      "gui": "ipi",
      "module_rules": [
        {"name": "enable", "flag": "bool", "display": "Enable", "desc": "Write inter-processor interrupts", "choices": [
            {"choice": true, "children": [
                {"name": "ipi_ctrl", "action": "write_if_set", "children": [
                    {"name": "slverr_enable", "flag": "bool", "output": 1, "lsb": 0, "desc": "assert SLVERR for unimplemented register accesses"}
                  ]
                },
                {"name": "ipi_prot_ctrl", "action": "write", "offset": "0x34", "children": [
                    {"name": "hide_error", "flag": "bool", "output": 1, "lsb": 2, "desc": "Hide NoC error response if a transaction check fails"},
                    {"name": "mid_parity_en", "output": 1, "lsb": 1, "desc": "Enable parity error checking for master IDs"},
                    {"name": "enable", "output": 1, "lsb": 0, "desc": "Permission checking"}
                  ]
                },
                {"name": "lock", "flag": "bool", "output": 1, "action": "write_if_set", "offset": "0x90", "desc": "Prevent changes until power-on-reset"}
              ]
            }
          ]
        }
      ]
    },
    "noc_nmu": {
      "display": "NoC NMUs",
      "gui": "noc_nmu",
      "access_rules": [
        {"name": "REG_SMID_SEL", "action": "write", "offset": "0x45c", "children": [
            {"name": "val", "output": "smid", "lsb": 10},
            {"name": "en", "output": "mask", "lsb": 0}
          ]
        },
        {"name": "REG_RD_AXPROT_SEL", "action_enable": "secure_rd != 0", "action": "write", "offset": "0x468", "children": [
            {"name": "val", "output": "secure_rd == 2 ? 0 : 2", "lsb": 3},
            {"name": "mask", "output": 2, "lsb": 0}
          ]
        },
        {"name": "REG_WD_AXPROT_SEL", "action_enable": "secure_wr != 0", "action": "write", "offset": "0x46c", "children": [
            {"name": "val", "output": "secure_wr == 2 ? 0 : 2", "lsb": 3},
            {"name": "mask", "output": 2, "lsb": 0}
          ]
        }
      ]
    },
    "secure_reg_access": {
      "constants": {"destinationZeroBits": 2, "max_num_nodes_defined": 32, "max_range_per_regNode": 1020, "regions": 0, "userdef_nodeID_base": "0x30100001"},
      "access_rules": [
        {"flag": "radio_group", "display": "Access Mode", "children": [
            {"flag": "radio_default", "display": "read/write", "desc": "read and write access"},
            {"name": "read_only", "flag": "bool", "display": "read only", "desc": "allow read access"}
          ]
        },
        {"flag": "radio_group", "display": "Secure Mode", "children": [
            {"flag": "radio_default", "display": "non-secure"},
            {"name": "secure", "flag": "bool"}
          ]
        }
      ],
      "module_rules": [
        {"name": "enable", "flag": "bool", "desc": "Enable SECURE REG ACCESS"}
      ]
    },
    "plm": {
      "group": "Firmware",
      "module_rules": [
        {"name": "image_store", "flag": "group", "action_enable": "PLM_image_store.size", "display": "PLM Image Store", "children": [
            {"name": "PMC_FW_CONFIG/IMG_STORE", "action": "marker_begin"},
            {"name": "PLM_image_store", "flag": "access_dest", "read_only": true, "display": "Destination", "desc": "Image store destination"},
            {"name": "PLM_image_store.addr", "flag": "hex", "read_only": true, "display": "Address", "desc": "Image store address"},
            {"name": "PLM_image_store.size", "flag": "size", "read_only": true, "display": "Size", "desc": "Image store size"},
            {"name": "image_store.addr_high", "output": "PLM_image_store.addr >> 32", "action": "write", "offset": "0x288", "desc": "Image Store Address High 32 bits"},
            {"name": "image_store.addr_low", "output": "PLM_image_store.addr & 0xffffffff", "action": "write", "offset": "0x28c", "desc": "Image Store Address Low 32 bits"},
            {"name": "image_store.size", "output": "PLM_image_store.size", "action": "write", "offset": "0x290", "desc": "Image Store Size"},
            {"action": "marker_end"}
          ]
        },
        {"name": "logging", "flag": "group", "display": "Event Logging", "children": [
            {"name": "plm_uart", "flag": "int", "default": 0, "display": "Select Uart", "desc": "Choose the UART to be used by PLM", "choices": [
                {"choice": 0, "display": "Default"},
                {"choice": 1, "display": "UART 0"},
                {"choice": 2, "display": "UART 1"},
                {"choice": -1, "display": "None"}
              ]
            },
            {"name": "log_level", "flag": "int", "default": 0, "display": "Log Level", "desc": "Choose event logging level", "choices": [
                {"choice": 0, "display": "Default"},
                {"choice": 1, "display": "Unconditional messages"},
                {"choice": 3, "display": "General debug messages"},
                {"choice": 7, "display": "More debug information"},
                {"choice": 15, "display": "Detailed debug information"}
              ]
            },
            {"name": "configure_uart", "action_enable": "plm_uart", "action": "event_logging", "offset": "0x8", "children": [
                {"name": "uart_select", "output": "plm_uart >= 0 ? plm_uart : 0"},
                {"name": "uart_enable", "output": "plm_uart >= 0"}
              ]
            },
            {"name": "configure_log_level", "action_enable": "log_level", "action": "event_logging", "offset": "0x1", "children": [
                {"name": "level", "output": "log_level"}
              ]
            }
          ]
        },
        {"name": "RTCA_SecureCtrl", "action_enable": "!pdi_copy_optimization | clear_red_keys | kat_on_config", "children": [
            {"name": "PMC_FW_CONFIG/SECURE_CTRL", "action": "marker_begin"},
            {"name": "RTCA_SecureCtrl", "action": "mask_write", "offset": "0x28", "mask": "0x3f", "children": [
                {"name": "Boot Optimization", "flag": "group", "children": [
                    {"name": "pdi_copy_optimization", "flag": "bool", "default": true, "display": "Boot Copy Optimization", "desc": "Enable the boot-pdi copy optimization so DMA masters can directly access the destination memory. Requires the boot device to have access to the destination memory and PSM memory."}
                  ]
                },
                {"name": "copy_optimization", "cond": "!pdi_copy_optimization", "output": 3, "lsb": 4},
                {"name": "Secure Control", "flag": "group", "children": [
                    {"name": "clear_red_keys", "flag": "bool", "output": 3, "lsb": 2, "display": "Clear Red Keys", "desc": "Clear Red Keys (clear-text keys) stored in the key management after the boot is complete."},
                    {"name": "kat_on_config", "flag": "bool", "output": 3, "lsb": 0, "display": "KAT on Config", "desc": "Execute known answer test to compare partial PDI signature with known good PDI signature"}
                  ]
                }
              ]
            },
            {"action": "marker_end"}
          ]
        },
        {"name": "boot_device_release", "action_enable": "skip_qspi_release | skip_sd_release | skip_sd_raw_release | skip_ospi_release | skip_usb_release | skip_ufs_release", "children": [
            {"name": "PMC_FW_CONFIG/BOOT_DEV_RELEASE", "action": "marker_begin"},
            {"name": "Boot Device Release Control", "flag": "group", "display": "Boot Device Release Configuration", "desc": "Configure which boot devices should remain accessible after boot completion", "children": [
                {"name": "skip_qspi_release", "flag": "bool", "default": false, "display": "Keep QSPI Accessible", "desc": "Prevent PLM from releasing QSPI boot device after boot. Applies to QSPI24 and QSPI32 boot modes."},
                {"name": "skip_sd_release", "flag": "bool", "default": false, "display": "Keep SD/eMMC Accessible", "desc": "Prevent PLM from releasing SD/eMMC boot devices after boot. Applies to SD0, SD1, SD1_LS, EMMC0, EMMC1 boot modes (Versal) or SDLS_B0, SD_B1, SDLS_B1, EMMC0, EMMC1 (VersalNet)."},
                {"name": "skip_sd_raw_release", "flag": "bool", "default": false, "display": "Keep SD/eMMC RAW Accessible", "desc": "Prevent PLM from releasing SD/eMMC RAW boot devices after boot. Applies to SD0_RAW, SD1_RAW, SD1_LS_RAW, EMMC_RAW, EMMC_RAW_BP1, EMMC_RAW_BP2, EMMC0_RAW boot modes."},
                {"name": "skip_ospi_release", "flag": "bool", "default": false, "display": "Keep OSPI Accessible", "desc": "Prevent PLM from releasing OSPI boot device after boot. Applies to OSPI boot mode."},
                {"name": "skip_usb_release", "flag": "bool", "default": false, "display": "Keep USB Accessible", "desc": "Prevent PLM from releasing USB boot device after boot. Applies to USB boot mode."},
                {"name": "skip_ufs_release", "flag": "bool", "default": false, "display": "Keep UFS Accessible", "desc": "Prevent PLM from releasing UFS boot device after boot. Applies to UFS boot mode."}
              ]
            },
            {"name": "RTCA_BootDevRelease", "action": "mask_write", "offset": "0x36c", "mask": "0x3f", "desc": "XPLMI_RTCFG_SKIP_BOOT_DEV_RELEASE register configuration", "children": [
                {"name": "qspi_bit", "cond": "skip_qspi_release", "output": 1, "lsb": 0, "desc": "Bit 0: Skip QSPI release"},
                {"name": "sd_bit", "cond": "skip_sd_release", "output": 1, "lsb": 1, "desc": "Bit 1: Skip SD/eMMC release"},
                {"name": "sd_raw_bit", "cond": "skip_sd_raw_release", "output": 1, "lsb": 2, "desc": "Bit 2: Skip SD/eMMC RAW release"},
                {"name": "ospi_bit", "cond": "skip_ospi_release", "output": 1, "lsb": 3, "desc": "Bit 3: Skip OSPI release"},
                {"name": "usb_bit", "cond": "skip_usb_release", "output": 1, "lsb": 4, "desc": "Bit 4: Skip USB release"},
                {"name": "ufs_bit", "cond": "skip_ufs_release", "output": 1, "lsb": 5, "desc": "Bit 5: Skip UFS release"}
              ]
            },
            {"action": "marker_end"}
          ]
        }
      ]
    },
    "lpd_slcr": {
      "module_rules": [
        {"action_enable": "lpd_dma_coherent", "comment": "lpd_dma_coherent is set by unit code", "children": [
            {"name": "LPD_DATA/SLCR", "action": "marker_begin"},
            {"name": "wprot0_en", "output": 0, "action": "write", "desc": "enable writes"},
            {"name": "LPD_APU", "action": "mask_write", "offset": "0xa040", "mask": "0x2", "children": [
                {"name": "brdc_inner", "cond": "lpd_dma_coherent", "output": 1, "lsb": 1, "desc": "CR-1201211 LPD_APU broadcast inner shareable bit should be set (0xFF41A040) if coherency is enabled for at least for one DMA master"}
              ]
            },
            {"name": "wprot0", "output": 1, "action": "write", "desc": "disable writes"},
            {"action": "marker_end"}
          ]
        }
      ]
    },
    "pmc_iou_slcr": {
      "module_rules": [
        {"action_enable": "write_subsystems", "comment": "set by code", "children": [
            {"name": "SD_eMMC0.coherent", "flag": "bool", "hide": true},
            {"name": "SD_eMMC1.coherent", "flag": "bool", "hide": true},
            {"name": "QSPI.coherent", "flag": "bool", "hide": true},
            {"name": "OSPI.coherent", "flag": "bool", "hide": true},
            {"name": "SD0_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "SD_eMMC0.coherent", "action": "write", "offset": "0x464"},
            {"name": "SD1_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "SD_eMMC1.coherent", "action": "write", "offset": "0x4e4"},
            {"name": "QSPI_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "QSPI.coherent", "action": "write", "offset": "0x50c"},
            {"name": "OSPI_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "OSPI.coherent", "action": "write", "offset": "0x534"}
          ]
        }
      ]
    },
    "lpd_iou_slcr": {
      "module_rules": [
        {"action_enable": "write_subsystems", "comment": "set by code", "children": [
            {"name": "GEM0.coherent", "flag": "bool", "hide": true},
            {"name": "GEM1.coherent", "flag": "bool", "hide": true},
            {"name": "USB2_CSR.coherent", "flag": "bool", "hide": true},
            {"name": "GEM0_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "GEM0.coherent", "action": "write", "offset": "0x328"},
            {"name": "GEM1_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "GEM1.coherent", "action": "write", "offset": "0x348"},
            {"name": "USB_IOU_INTERCONNECT_ROUTE", "output": 1, "action_enable": "USB2_CSR.coherent", "action": "write", "offset": "0x428"}
          ]
        }
      ]
    },
    "INTLPD_CONFIG": {
      "module_rules": [
        {"action_enable": "write_subsystems", "comment": "set by code", "children": [
            {"name": "LPD_DMA_CH0.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH1.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH2.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH3.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH4.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH5.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH6.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA_CH7.coherent", "flag": "bool", "hide": true},
            {"name": "LPD_DMA.coherent", "flag": "bool", "hide": true, "default": "LPD_DMA_CH0.coherent | LPD_DMA_CH1.coherent | LPD_DMA_CH2.coherent | LPD_DMA_CH3.coherent | LPD_DMA_CH4.coherent | LPD_DMA_CH5.coherent | LPD_DMA_CH6.coherent | LPD_DMA_CH7.coherent"},
            {"name": "RPU0.coherent", "flag": "bool", "hide": true},
            {"name": "RPU1.coherent", "flag": "bool", "hide": true},
            {"name": "adma", "output": 1, "action_enable": "LPD_DMA.coherent", "action": "write", "offset": "0x14"},
            {"name": "rpu0", "output": 1, "action_enable": "RPU0.coherent | RPU1.coherent", "action": "write", "offset": "0x1c"},
            {"name": "rpu1", "output": 1, "action_enable": "RPU0.coherent | RPU1.coherent", "action": "write", "offset": "0x20"}
          ]
        }
      ]
    },
    "ipi_perm": {
      "display": "IPI Permissions",
      "group": "Inter-Processor Interrupts",
      "gui": "ipi_perm",
      "module_rules": [
        {"name": "columns", "flag": "group", "children": [
            {"name": "IPI5", "flag": "int", "lsb": 14},
            {"name": "IPI4", "flag": "int", "lsb": 12},
            {"name": "IPI3", "flag": "int", "lsb": 10},
            {"name": "IPI2", "flag": "int", "lsb": 8},
            {"name": "IPI1", "flag": "int", "lsb": 6},
            {"name": "IPI0", "flag": "int", "lsb": 4},
            {"name": "IPI_PSM", "flag": "int", "lsb": 0}
          ]
        },
        {"name": "enable", "flag": "bool", "display": "Enable", "desc": "Write inter-processor interrupts", "choices": [
            {"choice": true, "children": [
                {"flag": "group", "display": "PLM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/PLM", "action": "marker_begin"},
                    {"name": "plmi_features", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x100", "display": "plmi_features (0x0)", "desc": "Checks if an Api Id is valid for the plmi module"},
                    {"name": "get_device_id", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x112", "display": "get_device_id (0x12)", "desc": "Get device id value"},
                    {"name": "event_logging", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x113", "display": "event_logging (0x13)", "desc": "Event logging operations"},
                    {"name": "get_board", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x115", "display": "get_board (0x15)", "desc": "Get Board Name"},
                    {"name": "tamper_trigger", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x123", "display": "tamper_trigger (0x23)", "desc": "Trigger Tamper Response"},
                    {"name": "configure_secure_communication", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x12b", "display": "configure_secure_communication (0x2b)", "desc": "Configures secure communication between master and slave SLR"},
                    {"name": "get_secure_communication_status", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x12d", "display": "get_secure_communication_status (0x2d)", "desc": "Read secure communication status between master and slave SLR"},
                    {"name": "DDRMC_MainReg_StatusSet", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x12e", "display": "DDRMC_MainReg_StatusSet (0x2e)", "desc": "Sets the access status of DDRMC main registers"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PLM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/PM", "action": "marker_begin"},
                    {"name": "pm_get_api_version", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x201", "display": "pm_get_api_version (0x1)", "desc": "Gives version number of the API"},
                    {"name": "pm_get_node_status", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x203", "display": "pm_get_node_status (0x3)", "desc": "Obtains information about the current state of device"},
                    {"name": "pm_get_op_characteristic", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x204", "display": "pm_get_op_characteristic (0x4)", "desc": "Gets operating characteristics of a device"},
                    {"name": "pm_register_notifier", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x205", "display": "pm_register_notifier (0x5)", "desc": "Register a subsystem to be notified about the device event"},
                    {"name": "pm_request_suspend", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x206", "display": "pm_request_suspend (0x6)", "desc": "Send suspend request  to another subsystem"},
                    {"name": "pm_self_suspend", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x207", "display": "pm_self_suspend (0x7)", "desc": "Suspend a child subsystem"},
                    {"name": "pm_force_powerdown", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x208", "display": "pm_force_powerdown (0x8)", "desc": "Powerdown other processor or domain node or subsystem forcefull"},
                    {"name": "pm_abort_suspend", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x209", "display": "pm_abort_suspend (0x9)", "desc": "Aborting suspend of a child subsystem."},
                    {"name": "pm_request_wakeup", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20a", "display": "pm_request_wakeup (0xa)", "desc": "Start-up and wake-up a child subsyste"},
                    {"name": "pm_set_wakeup_source", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20b", "display": "pm_set_wakeup_source (0xb)", "desc": "Set wake up source"},
                    {"name": "pm_system_shutdown", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20c", "display": "pm_system_shutdown (0xc)", "desc": "Shutdown self or restart self, Ps or system"},
                    {"name": "pm_request_node", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20d", "display": "pm_request_node (0xd)", "desc": "Request the usage of a device"},
                    {"name": "pm_release_node", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20e", "display": "pm_release_node (0xe)", "desc": "Release the usage of a device"},
                    {"name": "pm_set_requirement", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x20f", "display": "pm_set_requirement (0xf)", "desc": "Announce a change in requirements for a specific device which is currently in use"},
                    {"name": "pm_set_max_latency", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x210", "display": "pm_set_max_latency (0x10)", "desc": "Set maximum allowed latency for the device"},
                    {"name": "pm_reset_assert", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x211", "display": "pm_reset_assert (0x11)", "desc": "Reset or de-reset a device"},
                    {"name": "pm_reset_get_status", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x212", "display": "pm_reset_get_status (0x12)", "desc": "Reads the device reset state"},
                    {"name": "pm_init_finalize", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x215", "display": "pm_init_finalize (0x15)", "desc": "Initializes subsystem and releases unused devices"},
                    {"name": "pm_get_chipid", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x218", "display": "pm_get_chipid (0x18)", "desc": "Request the version and ID code of a chip"},
                    {"name": "pm_pinctrl_request", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x21c", "display": "pm_pinctrl_request (0x1c)", "desc": "Requests the pin."},
                    {"name": "pm_pinctrl_release", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x21d", "display": "pm_pinctrl_release (0x1d)", "desc": "Release the pin."},
                    {"name": "pm_pinctrl_get_function", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x21e", "display": "pm_pinctrl_get_function (0x1e)", "desc": "Reads the pin function"},
                    {"name": "pm_pinctrl_set_function", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x21f", "display": "pm_pinctrl_set_function (0x1f)", "desc": "Sets the pin function"},
                    {"name": "pm_pinctrl_config_param_get", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x220", "display": "pm_pinctrl_config_param_get (0x20)", "desc": "Reads the pin parameter value"},
                    {"name": "pm_pinctrl_config_param_set", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x221", "display": "pm_pinctrl_config_param_set (0x21)", "desc": "Sets the pin parameter value"},
                    {"name": "pm_ioctl", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x222", "display": "pm_ioctl (0x22)", "desc": "Performs driver-like IOCTL functions on shared system device"},
                    {"name": "pm_query_data", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x223", "display": "pm_query_data (0x23)", "desc": "Queries information about the platform resources"},
                    {"name": "pm_clock_enable", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x224", "display": "pm_clock_enable (0x24)", "desc": "Enables the clock"},
                    {"name": "pm_clock_disable", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x225", "display": "pm_clock_disable (0x25)", "desc": "Disables the clock"},
                    {"name": "pm_clock_getstate", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x226", "display": "pm_clock_getstate (0x26)", "desc": "Reads the clock state"},
                    {"name": "pm_clock_setdivider", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x227", "display": "pm_clock_setdivider (0x27)", "desc": "Sets the divider value of the clock"},
                    {"name": "pm_clock_getdivider", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x228", "display": "pm_clock_getdivider (0x28)", "desc": "Gets the divider value of the clock"},
                    {"name": "pm_clock_setparent", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x22b", "display": "pm_clock_setparent (0x2b)", "desc": "Sets the parent of the clock"},
                    {"name": "pm_clock_getparent", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x22c", "display": "pm_clock_getparent (0x2c)", "desc": "Gets the parent of the clock"},
                    {"name": "pm_pll_set_parameter", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x230", "display": "pm_pll_set_parameter (0x30)", "desc": "Sets the parameter of PLL clock"},
                    {"name": "pm_pll_get_parameter", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x231", "display": "pm_pll_get_parameter (0x31)", "desc": "Gets the parameter of PLL clock"},
                    {"name": "pm_pll_set_mode", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x232", "display": "pm_pll_set_mode (0x32)", "desc": "Sets the mode of PLL clock"},
                    {"name": "pm_pll_get_mode", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x233", "display": "pm_pll_get_mode (0x33)", "desc": "Gets the mode of PLL clock"},
                    {"name": "pm_activate_subsystem", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x241", "display": "pm_activate_subsystem (0x41)", "desc": "Activates subsystem"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "SEM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/SEM", "action": "marker_begin"},
                    {"name": "cram_init", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x301", "display": "cram_init (0x1)", "desc": "Cram Initialize"},
                    {"name": "cram_start", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x302", "display": "cram_start (0x2)", "desc": "Cram Start"},
                    {"name": "cram_stop", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x303", "display": "cram_stop (0x3)", "desc": "Cram Stop"},
                    {"name": "cram_error_injection", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x304", "display": "cram_error_injection (0x4)", "desc": "Cram Error Injection"},
                    {"name": "npi_start", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x305", "display": "npi_start (0x5)", "desc": "Npi Start"},
                    {"name": "npi_stop", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x306", "display": "npi_stop (0x6)", "desc": "Npi Stop"},
                    {"name": "npi_error_injection", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x307", "display": "npi_error_injection (0x7)", "desc": "Npi Error Injection"},
                    {"name": "sem_event_register", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x308", "display": "sem_event_register (0x8)", "desc": "Register for SEM Event"},
                    {"name": "sem_read_config", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x309", "display": "sem_read_config (0x9)", "desc": "Sem Read Config"},
                    {"name": "sem_read_npi_golden_sha", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x30a", "display": "sem_read_npi_golden_sha (0xa)", "desc": "Read NPI Golden SHA"},
                    {"name": "sem_cram_read_frame_ecc", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x30b", "display": "sem_cram_read_frame_ecc (0xb)", "desc": "Read CRAM Frame ECC"},
                    {"name": "sem_ssit_read_golden_sha", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x30c", "display": "sem_ssit_read_golden_sha (0xc)", "desc": "Read Golden SHA SSIT"},
                    {"name": "sem_ssit_read_status", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x30d", "display": "sem_ssit_read_status (0xd)", "desc": "Read SEM Status SSIT"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for SEM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "SECURE", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/SECURE", "action": "marker_begin"},
                    {"name": "secure_features", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x500", "display": "secure_features (0x0)", "desc": "Secure Features"},
                    {"name": "rsa_sign_verify", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x501", "display": "rsa_sign_verify (0x1)", "desc": "Rsa signature verification"},
                    {"name": "rsa_public_encrypt", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x502", "display": "rsa_public_encrypt (0x2)", "desc": "RSA public encryption"},
                    {"name": "rsa_private_decrypt", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x503", "display": "rsa_private_decrypt (0x3)", "desc": "RSA private decryption"},
                    {"name": "sha3_update", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x504", "display": "sha3_update (0x4)", "desc": "SHA3 digest calculation"},
                    {"name": "elliptic_generate_key", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x505", "display": "elliptic_generate_key (0x5)", "desc": "Ecc public key generation"},
                    {"name": "elliptic_generate_sign", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x506", "display": "elliptic_generate_sign (0x6)", "desc": "Ecc signature generation"},
                    {"name": "elliptic_validate_key", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x507", "display": "elliptic_validate_key (0x7)", "desc": "Ecc validate public key"},
                    {"name": "elliptic_verify_sign", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x508", "display": "elliptic_verify_sign (0x8)", "desc": "Ecc verify signature"},
                    {"name": "aes_init", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x509", "display": "aes_init (0x9)", "desc": "Aes initialize"},
                    {"name": "aes_op_init", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50a", "display": "aes_op_init (0xa)", "desc": "Aes Encryption/Decryption init"},
                    {"name": "aes_update_aad", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50b", "display": "aes_update_aad (0xb)", "desc": "Aes AAD update"},
                    {"name": "aes_encrypt_update", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50c", "display": "aes_encrypt_update (0xc)", "desc": "Aes Encrypt Update"},
                    {"name": "aes_encrypt_final", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50d", "display": "aes_encrypt_final (0xd)", "desc": "Aes Encrypt Final"},
                    {"name": "aes_decrypt_update", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50e", "display": "aes_decrypt_update (0xe)", "desc": "Aes Decrypt Update"},
                    {"name": "aes_decrypt_final", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x50f", "display": "aes_decrypt_final (0xf)", "desc": "Aes Decrypt Final"},
                    {"name": "aes_key_zero", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x510", "display": "aes_key_zero (0x10)", "desc": "Aes Key Zero"},
                    {"name": "aes_write_key", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x511", "display": "aes_write_key (0x11)", "desc": "Aes Write Key"},
                    {"name": "aes_lock_user_key", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x512", "display": "aes_lock_user_key (0x12)", "desc": "Aes Lock User Key"},
                    {"name": "aes_kek_decrypt", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x513", "display": "aes_kek_decrypt (0x13)", "desc": "Aes Kek Decrypt"},
                    {"name": "aes_set_dpa_cm", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x514", "display": "aes_set_dpa_cm (0x14)", "desc": "Aes Set Dpa Cm"},
                    {"name": "kat", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x515", "display": "kat (0x15)", "desc": "Kats of crypto engines"},
                    {"name": "aes_perform_operation", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x517", "display": "aes_perform_operation (0x17)", "desc": "Aes Perform Operation"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for SECURE"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PSM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/PSM", "action": "marker_begin"},
                    {"name": "pm_psm_to_plm_event", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x601", "display": "pm_psm_to_plm_event (0x1)", "desc": "PSM to PLM Event"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PSM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "LOADER", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/LOADER", "action": "marker_begin"},
                    {"name": "loader_features", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x700", "display": "loader_features (0x0)", "desc": "Loader Features"},
                    {"name": "load_subsystem_pdi", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x701", "display": "load_subsystem_pdi (0x1)", "desc": "Load Subsystem PDI"},
                    {"name": "load_ddrcpy_img", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x702", "display": "load_ddrcpy_img (0x2)", "desc": "Load Image from Image Store"},
                    {"name": "get_image_info", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x703", "display": "get_image_info (0x3)", "desc": "Get Image Info"},
                    {"name": "get_image_info_list", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x705", "display": "get_image_info_list (0x5)", "desc": "Get Image Info List"},
                    {"name": "extract_metaheader", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x706", "display": "extract_metaheader (0x6)", "desc": "Extract metaheader from PDI"},
                    {"name": "load_readback_pdi", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x707", "display": "load_readback_pdi (0x7)", "desc": "Load Readback PDI"},
                    {"name": "update_multiboot", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0x708", "display": "update_multiboot (0x8)", "desc": "Update Multiboot Register"},
                    {"name": "add_image_store_pdi", "flag": "hex", "default": "0xfff0", "action": "set_ipi_access", "offset": "0x709", "display": "add_image_store_pdi (0x9)", "desc": "Add PDI to Image Store"},
                    {"name": "remove_image_store_pdi", "flag": "hex", "default": "0xfff0", "action": "set_ipi_access", "offset": "0x70a", "display": "remove_image_store_pdi (0xa)", "desc": "Remove PDI from Image Store"},
                    {"name": "get_atf_handoff_params", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x70b", "display": "get_atf_handoff_params (0xb)", "desc": "Get ATF Handoff Parameters"},
                    {"name": "Cfi_selective_readback", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x712", "display": "Cfi_selective_readback (0x12)", "desc": "Reads given number of cframes from the start frame given"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for LOADER"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "EM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/EM", "action": "marker_begin"},
                    {"name": "em_features", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x800", "display": "em_features (0x0)", "desc": "Error Management Features"},
                    {"name": "em_set_action", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0x801", "display": "em_set_action (0x1)", "desc": "Set Error Action"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for EM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "NVM", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/NVM", "action": "marker_begin"},
                    {"name": "nvm_features", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb00", "display": "nvm_features (0x0)", "desc": "Features of XilNvm"},
                    {"name": "bbram_write_aes_key", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb01", "display": "bbram_write_aes_key (0x1)", "desc": "Bbram Write Aes Key"},
                    {"name": "bbram_zeroize", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb02", "display": "bbram_zeroize (0x2)", "desc": "Zeroize bbram"},
                    {"name": "bbram_write_user_data", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb03", "display": "bbram_write_user_data (0x3)", "desc": "Bbram Write User Data"},
                    {"name": "bbram_read_user_data", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb04", "display": "bbram_read_user_data (0x4)", "desc": "Bbram Read User Data"},
                    {"name": "bbram_lock_write_user_data", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb05", "display": "bbram_lock_write_user_data (0x5)", "desc": "Bbram Lock Write User Data"},
                    {"name": "efuse_write", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb06", "display": "efuse_write (0x6)", "desc": "Efuse write"},
                    {"name": "efuse_write_puf", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb07", "display": "efuse_write_puf (0x7)", "desc": "Efuse write PUF"},
                    {"name": "efuse_puf_user_fuse_write", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xb08", "display": "efuse_puf_user_fuse_write (0x8)", "desc": "Efuse puf user fuse write"},
                    {"name": "efuse_read_iv", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb09", "display": "efuse_read_iv (0x9)", "desc": "Efuse read iv"},
                    {"name": "efuse_read_revocation_id", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0a", "display": "efuse_read_revocation_id (0xa)", "desc": "Efuse read revocation id"},
                    {"name": "efuse_read_offchip_revocation_id", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0b", "display": "efuse_read_offchip_revocation_id (0xb)", "desc": "Efuse read offchip revocation id"},
                    {"name": "efuse_read_user_fuses", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0c", "display": "efuse_read_user_fuses (0xc)", "desc": "Efuse read user fuses"},
                    {"name": "efuse_read_misc_ctrl_bits", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0d", "display": "efuse_read_misc_ctrl_bits (0xd)", "desc": "Efuse read misc ctrl bits"},
                    {"name": "efuse_read_sec_ctrl_bits", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0e", "display": "efuse_read_sec_ctrl_bits (0xe)", "desc": "Efuse read sec ctrl bits"},
                    {"name": "efuse_read_sec_misc1_bits", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb0f", "display": "efuse_read_sec_misc1_bits (0xf)", "desc": "Efuse read sec misc bits"},
                    {"name": "efuse_read_boot_env_ctrl_bits", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb10", "display": "efuse_read_boot_env_ctrl_bits (0x10)", "desc": "Efuse read boot env ctrl bits"},
                    {"name": "efuse_read_puf_sec_ctrl_bits", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb11", "display": "efuse_read_puf_sec_ctrl_bits (0x11)", "desc": "Efuse read PUF sec ctrl bits"},
                    {"name": "efuse_read_ppk_hash", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb12", "display": "efuse_read_ppk_hash (0x12)", "desc": "Efuse read ppk hash"},
                    {"name": "efuse_read_dec_efuse_only", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb13", "display": "efuse_read_dec_efuse_only (0x13)", "desc": "Efuse read dec efuse only"},
                    {"name": "efuse_read_dna", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb14", "display": "efuse_read_dna (0x14)", "desc": "Efuse read dna"},
                    {"name": "efuse_read_puf_user_fuse", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb15", "display": "efuse_read_puf_user_fuse (0x15)", "desc": "Efuse read PUF user fuse"},
                    {"name": "efuse_read_puf", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xb16", "display": "efuse_read_puf (0x16)", "desc": "Read Efuse PUF"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for NVM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PUF", "children": [
                    {"name": "PMC_FW_CONFIG/IPI_ACCESS_PERM/PUF", "action": "marker_begin"},
                    {"name": "puf_features", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xc00", "display": "puf_features (0x0)", "desc": "PUF features"},
                    {"name": "puf_registration", "flag": "hex", "default": "0x5551", "action": "set_ipi_access", "offset": "0xc01", "display": "puf_registration (0x1)", "desc": "PUF registration"},
                    {"name": "puf_regeneration", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xc02", "display": "puf_regeneration (0x2)", "desc": "PUF regeneration"},
                    {"name": "puf_clear_puf_id", "flag": "hex", "default": "0xfff3", "action": "set_ipi_access", "offset": "0xc03", "display": "puf_clear_puf_id (0x3)", "desc": "Clear PUF id"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PUF"},
                    {"action": "marker_end"}
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    "ipi_perm_slr": {
      "display": "IPI Permissions",
      "group": "Inter-Processor Interrupts",
      "gui": "ipi_perm",
      "module_rules": [
        {"name": "columns", "flag": "group", "children": [
            {"name": "FROM SLR0", "flag": "int", "lsb": 2}
          ]
        },
        {"name": "enable", "flag": "bool", "display": "Enable", "desc": "Write inter-processor interrupts", "choices": [
            {"choice": true, "children": [
                {"flag": "group", "display": "PLM", "children": [
                    {"name": "IPI_ACCESS_PERM/PLM", "action": "submarker_begin"},
                    {"name": "plmi_features", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x100", "display": "plmi_features (0x0)", "desc": "Checks if an Api Id is valid for the plmi module"},
                    {"name": "get_device_id", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x112", "display": "get_device_id (0x12)", "desc": "Get device id value"},
                    {"name": "event_logging", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x113", "display": "event_logging (0x13)", "desc": "Event logging operations"},
                    {"name": "get_board", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x115", "display": "get_board (0x15)", "desc": "Get Board Name"},
                    {"name": "tamper_trigger", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x123", "display": "tamper_trigger (0x23)", "desc": "Trigger Tamper Response"},
                    {"name": "configure_secure_communication", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x12b", "display": "configure_secure_communication (0x2b)", "desc": "Configures secure communication between master and slave SLR"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PLM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PM", "children": [
                    {"name": "IPI_ACCESS_PERM/PM", "action": "submarker_begin"},
                    {"name": "pm_get_api_version", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x201", "display": "pm_get_api_version (0x1)", "desc": "Gives version number of the API"},
                    {"name": "pm_get_node_status", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x203", "display": "pm_get_node_status (0x3)", "desc": "Obtains information about the current state of device"},
                    {"name": "pm_get_op_characteristic", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x204", "display": "pm_get_op_characteristic (0x4)", "desc": "Gets operating characteristics of a device"},
                    {"name": "pm_register_notifier", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x205", "display": "pm_register_notifier (0x5)", "desc": "Register a subsystem to be notified about the device event"},
                    {"name": "pm_request_suspend", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x206", "display": "pm_request_suspend (0x6)", "desc": "Send suspend request  to another subsystem"},
                    {"name": "pm_self_suspend", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x207", "display": "pm_self_suspend (0x7)", "desc": "Suspend a child subsystem"},
                    {"name": "pm_force_powerdown", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x208", "display": "pm_force_powerdown (0x8)", "desc": "Powerdown other processor or domain node or subsystem forcefull"},
                    {"name": "pm_abort_suspend", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x209", "display": "pm_abort_suspend (0x9)", "desc": "Aborting suspend of a child subsystem."},
                    {"name": "pm_request_wakeup", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20a", "display": "pm_request_wakeup (0xa)", "desc": "Start-up and wake-up a child subsyste"},
                    {"name": "pm_set_wakeup_source", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20b", "display": "pm_set_wakeup_source (0xb)", "desc": "Set wake up source"},
                    {"name": "pm_system_shutdown", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20c", "display": "pm_system_shutdown (0xc)", "desc": "Shutdown self or restart self, Ps or system"},
                    {"name": "pm_request_node", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20d", "display": "pm_request_node (0xd)", "desc": "Request the usage of a device"},
                    {"name": "pm_release_node", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20e", "display": "pm_release_node (0xe)", "desc": "Release the usage of a device"},
                    {"name": "pm_set_requirement", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x20f", "display": "pm_set_requirement (0xf)", "desc": "Announce a change in requirements for a specific device which is currently in use"},
                    {"name": "pm_set_max_latency", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x210", "display": "pm_set_max_latency (0x10)", "desc": "Set maximum allowed latency for the device"},
                    {"name": "pm_reset_assert", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x211", "display": "pm_reset_assert (0x11)", "desc": "Reset or de-reset a device"},
                    {"name": "pm_reset_get_status", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x212", "display": "pm_reset_get_status (0x12)", "desc": "Reads the device reset state"},
                    {"name": "pm_init_finalize", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x215", "display": "pm_init_finalize (0x15)", "desc": "Initializes subsystem and releases unused devices"},
                    {"name": "pm_get_chipid", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x218", "display": "pm_get_chipid (0x18)", "desc": "Request the version and ID code of a chip"},
                    {"name": "pm_pinctrl_request", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x21c", "display": "pm_pinctrl_request (0x1c)", "desc": "Requests the pin."},
                    {"name": "pm_pinctrl_release", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x21d", "display": "pm_pinctrl_release (0x1d)", "desc": "Release the pin."},
                    {"name": "pm_pinctrl_get_function", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x21e", "display": "pm_pinctrl_get_function (0x1e)", "desc": "Reads the pin function"},
                    {"name": "pm_pinctrl_set_function", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x21f", "display": "pm_pinctrl_set_function (0x1f)", "desc": "Sets the pin function"},
                    {"name": "pm_pinctrl_config_param_get", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x220", "display": "pm_pinctrl_config_param_get (0x20)", "desc": "Reads the pin parameter value"},
                    {"name": "pm_pinctrl_config_param_set", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x221", "display": "pm_pinctrl_config_param_set (0x21)", "desc": "Sets the pin parameter value"},
                    {"name": "pm_ioctl", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x222", "display": "pm_ioctl (0x22)", "desc": "Performs driver-like IOCTL functions on shared system device"},
                    {"name": "pm_query_data", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x223", "display": "pm_query_data (0x23)", "desc": "Queries information about the platform resources"},
                    {"name": "pm_clock_enable", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x224", "display": "pm_clock_enable (0x24)", "desc": "Enables the clock"},
                    {"name": "pm_clock_disable", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x225", "display": "pm_clock_disable (0x25)", "desc": "Disables the clock"},
                    {"name": "pm_clock_getstate", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x226", "display": "pm_clock_getstate (0x26)", "desc": "Reads the clock state"},
                    {"name": "pm_clock_setdivider", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x227", "display": "pm_clock_setdivider (0x27)", "desc": "Sets the divider value of the clock"},
                    {"name": "pm_clock_getdivider", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x228", "display": "pm_clock_getdivider (0x28)", "desc": "Gets the divider value of the clock"},
                    {"name": "pm_clock_setparent", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x22b", "display": "pm_clock_setparent (0x2b)", "desc": "Sets the parent of the clock"},
                    {"name": "pm_clock_getparent", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x22c", "display": "pm_clock_getparent (0x2c)", "desc": "Gets the parent of the clock"},
                    {"name": "pm_pll_set_parameter", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x230", "display": "pm_pll_set_parameter (0x30)", "desc": "Sets the parameter of PLL clock"},
                    {"name": "pm_pll_get_parameter", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x231", "display": "pm_pll_get_parameter (0x31)", "desc": "Gets the parameter of PLL clock"},
                    {"name": "pm_pll_set_mode", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x232", "display": "pm_pll_set_mode (0x32)", "desc": "Sets the mode of PLL clock"},
                    {"name": "pm_pll_get_mode", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x233", "display": "pm_pll_get_mode (0x33)", "desc": "Gets the mode of PLL clock"},
                    {"name": "pm_activate_subsystem", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x241", "display": "pm_activate_subsystem (0x41)", "desc": "Activates subsystem"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "SEM", "children": [
                    {"name": "IPI_ACCESS_PERM/SEM", "action": "submarker_begin"},
                    {"name": "cram_init", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x301", "display": "cram_init (0x1)", "desc": "Cram Initialize"},
                    {"name": "cram_start", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x302", "display": "cram_start (0x2)", "desc": "Cram Start"},
                    {"name": "cram_stop", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x303", "display": "cram_stop (0x3)", "desc": "Cram Stop"},
                    {"name": "cram_error_injection", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x304", "display": "cram_error_injection (0x4)", "desc": "Cram Error Injection"},
                    {"name": "npi_start", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x305", "display": "npi_start (0x5)", "desc": "Npi Start"},
                    {"name": "npi_stop", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x306", "display": "npi_stop (0x6)", "desc": "Npi Stop"},
                    {"name": "npi_error_injection", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x307", "display": "npi_error_injection (0x7)", "desc": "Npi Error Injection"},
                    {"name": "sem_event_register", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x308", "display": "sem_event_register (0x8)", "desc": "Register for SEM Event"},
                    {"name": "sem_read_config", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x309", "display": "sem_read_config (0x9)", "desc": "Sem Read Config"},
                    {"name": "sem_read_npi_golden_sha", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x30a", "display": "sem_read_npi_golden_sha (0xa)", "desc": "Read NPI Golden SHA"},
                    {"name": "sem_cram_read_frame_ecc", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x30b", "display": "sem_cram_read_frame_ecc (0xb)", "desc": "Read CRAM Frame ECC"},
                    {"name": "sem_ssit_read_golden_sha", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x30c", "display": "sem_ssit_read_golden_sha (0xc)", "desc": "Read Golden SHA SSIT"},
                    {"name": "sem_ssit_read_status", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0x30d", "display": "sem_ssit_read_status (0xd)", "desc": "Read SEM Status SSIT"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for SEM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "SECURE", "children": [
                    {"name": "IPI_ACCESS_PERM/SECURE", "action": "submarker_begin"},
                    {"name": "secure_features", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x500", "display": "secure_features (0x0)", "desc": "Secure Features"},
                    {"name": "rsa_sign_verify", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x501", "display": "rsa_sign_verify (0x1)", "desc": "Rsa signature verification"},
                    {"name": "rsa_public_encrypt", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x502", "display": "rsa_public_encrypt (0x2)", "desc": "RSA public encryption"},
                    {"name": "rsa_private_decrypt", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x503", "display": "rsa_private_decrypt (0x3)", "desc": "RSA private decryption"},
                    {"name": "sha3_update", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x504", "display": "sha3_update (0x4)", "desc": "SHA3 digest calculation"},
                    {"name": "elliptic_generate_key", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x505", "display": "elliptic_generate_key (0x5)", "desc": "Ecc public key generation"},
                    {"name": "elliptic_generate_sign", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x506", "display": "elliptic_generate_sign (0x6)", "desc": "Ecc signature generation"},
                    {"name": "elliptic_validate_key", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x507", "display": "elliptic_validate_key (0x7)", "desc": "Ecc validate public key"},
                    {"name": "elliptic_verify_sign", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x508", "display": "elliptic_verify_sign (0x8)", "desc": "Ecc verify signature"},
                    {"name": "aes_init", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x509", "display": "aes_init (0x9)", "desc": "Aes initialize"},
                    {"name": "aes_op_init", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50a", "display": "aes_op_init (0xa)", "desc": "Aes Encryption/Decryption init"},
                    {"name": "aes_update_aad", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50b", "display": "aes_update_aad (0xb)", "desc": "Aes AAD update"},
                    {"name": "aes_encrypt_update", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50c", "display": "aes_encrypt_update (0xc)", "desc": "Aes Encrypt Update"},
                    {"name": "aes_encrypt_final", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50d", "display": "aes_encrypt_final (0xd)", "desc": "Aes Encrypt Final"},
                    {"name": "aes_decrypt_update", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50e", "display": "aes_decrypt_update (0xe)", "desc": "Aes Decrypt Update"},
                    {"name": "aes_decrypt_final", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x50f", "display": "aes_decrypt_final (0xf)", "desc": "Aes Decrypt Final"},
                    {"name": "aes_key_zero", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x510", "display": "aes_key_zero (0x10)", "desc": "Aes Key Zero"},
                    {"name": "aes_write_key", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x511", "display": "aes_write_key (0x11)", "desc": "Aes Write Key"},
                    {"name": "aes_lock_user_key", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x512", "display": "aes_lock_user_key (0x12)", "desc": "Aes Lock User Key"},
                    {"name": "aes_kek_decrypt", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x513", "display": "aes_kek_decrypt (0x13)", "desc": "Aes Kek Decrypt"},
                    {"name": "aes_set_dpa_cm", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x514", "display": "aes_set_dpa_cm (0x14)", "desc": "Aes Set Dpa Cm"},
                    {"name": "kat", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x515", "display": "kat (0x15)", "desc": "Kats of crypto engines"},
                    {"name": "aes_perform_operation", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0x517", "display": "aes_perform_operation (0x17)", "desc": "Aes Perform Operation"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for SECURE"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PSM", "children": [
                    {"name": "IPI_ACCESS_PERM/PSM", "action": "submarker_begin"},
                    {"name": "pm_psm_to_plm_event", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x601", "display": "pm_psm_to_plm_event (0x1)", "desc": "PSM to PLM Event"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PSM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "LOADER", "children": [
                    {"name": "IPI_ACCESS_PERM/LOADER", "action": "submarker_begin"},
                    {"name": "loader_features", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x700", "display": "loader_features (0x0)", "desc": "Loader Features"},
                    {"name": "load_subsystem_pdi", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x701", "display": "load_subsystem_pdi (0x1)", "desc": "Load Subsystem PDI"},
                    {"name": "load_ddrcpy_img", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x702", "display": "load_ddrcpy_img (0x2)", "desc": "Load Image from Image Store"},
                    {"name": "get_image_info", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x703", "display": "get_image_info (0x3)", "desc": "Get Image Info"},
                    {"name": "get_image_info_list", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x705", "display": "get_image_info_list (0x5)", "desc": "Get Image Info List"},
                    {"name": "extract_metaheader", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x706", "display": "extract_metaheader (0x6)", "desc": "Extract metaheader from PDI"},
                    {"name": "load_readback_pdi", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x707", "display": "load_readback_pdi (0x7)", "desc": "Load Readback PDI"},
                    {"name": "update_multiboot", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x708", "display": "update_multiboot (0x8)", "desc": "Update Multiboot Register"},
                    {"name": "add_image_store_pdi", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x709", "display": "add_image_store_pdi (0x9)", "desc": "Add PDI to Image Store"},
                    {"name": "remove_image_store_pdi", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x70a", "display": "remove_image_store_pdi (0xa)", "desc": "Remove PDI from Image Store"},
                    {"name": "get_atf_handoff_params", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x70b", "display": "get_atf_handoff_params (0xb)", "desc": "Get ATF Handoff Parameters"},
                    {"name": "Cfi_selective_readback", "flag": "hex", "default": "0x0", "action": "set_ipi_access", "offset": "0x712", "display": "Cfi_selective_readback (0x12)", "desc": "Reads given number of cframes from the start frame given"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for LOADER"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "NVM", "children": [
                    {"name": "IPI_ACCESS_PERM/NVM", "action": "submarker_begin"},
                    {"name": "nvm_features", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb00", "display": "nvm_features (0x0)", "desc": "Features of Xilnvm"},
                    {"name": "bbram_write_aes_key", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb01", "display": "bbram_write_aes_key (0x1)", "desc": "Bbram Write Aes Key"},
                    {"name": "bbram_zeroize", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb02", "display": "bbram_zeroize (0x2)", "desc": "Zeroize bbram"},
                    {"name": "bbram_write_user_data", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb03", "display": "bbram_write_user_data (0x3)", "desc": "Bbram Write User Data"},
                    {"name": "bbram_read_user_data", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb04", "display": "bbram_read_user_data (0x4)", "desc": "Bbram Read User Data"},
                    {"name": "bbram_lock_write_user_data", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb05", "display": "bbram_lock_write_user_data (0x5)", "desc": "Bbram Lock Write User Data"},
                    {"name": "efuse_write", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb06", "display": "efuse_write (0x6)", "desc": "Efuse write"},
                    {"name": "efuse_write_puf", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb07", "display": "efuse_write_puf (0x7)", "desc": "Efuse write puf"},
                    {"name": "efuse_puf_user_fuse_write", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xb08", "display": "efuse_puf_user_fuse_write (0x8)", "desc": "Efuse puf user fuse write"},
                    {"name": "efuse_read_iv", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb09", "display": "efuse_read_iv (0x9)", "desc": "Efuse read iv"},
                    {"name": "efuse_read_revocation_id", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0a", "display": "efuse_read_revocation_id (0xa)", "desc": "Efuse read revocation id"},
                    {"name": "efuse_read_offchip_revocation_id", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0b", "display": "efuse_read_offchip_revocation_id (0xb)", "desc": "Efuse read offchip revocation id"},
                    {"name": "efuse_read_user_fuses", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0c", "display": "efuse_read_user_fuses (0xc)", "desc": "Efuse read user fuses"},
                    {"name": "efuse_read_misc_ctrl_bits", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0d", "display": "efuse_read_misc_ctrl_bits (0xd)", "desc": "Efuse read misc ctrl bits"},
                    {"name": "efuse_read_sec_ctrl_bits", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0e", "display": "efuse_read_sec_ctrl_bits (0xe)", "desc": "Efuse read sec ctrl bits"},
                    {"name": "efuse_read_sec_misc1_bits", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb0f", "display": "efuse_read_sec_misc1_bits (0xf)", "desc": "Efuse read sec misc bits"},
                    {"name": "efuse_read_boot_env_ctrl_bits", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb10", "display": "efuse_read_boot_env_ctrl_bits (0x10)", "desc": "Efuse read boot env ctrl bits"},
                    {"name": "efuse_read_puf_sec_ctrl_bits", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb11", "display": "efuse_read_puf_sec_ctrl_bits (0x11)", "desc": "Efuse read puf sec ctrl bits"},
                    {"name": "efuse_read_ppk_hash", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb12", "display": "efuse_read_ppk_hash (0x12)", "desc": "Efuse read ppk hash"},
                    {"name": "efuse_read_dec_efuse_only", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb13", "display": "efuse_read_dec_efuse_only (0x13)", "desc": "Efuse read dec efuse only"},
                    {"name": "efuse_read_dna", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb14", "display": "efuse_read_dna (0x14)", "desc": "Efuse read dna"},
                    {"name": "efuse_read_puf_user_fuse", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb15", "display": "efuse_read_puf_user_fuse (0x15)", "desc": "Efuse read puf user fuse"},
                    {"name": "efuse_read_puf", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xb16", "display": "efuse_read_puf (0x16)", "desc": "Read Efuse puf"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for NVM"},
                    {"action": "marker_end"}
                  ]
                },
                {"flag": "group", "display": "PUF", "children": [
                    {"name": "IPI_ACCESS_PERM/PUF", "action": "submarker_begin"},
                    {"name": "puf_features", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xc00", "display": "puf_features (0x0)", "desc": "Puf features"},
                    {"name": "puf_registration", "flag": "hex", "default": "0x4", "action": "set_ipi_access", "offset": "0xc01", "display": "puf_registration (0x1)", "desc": "Puf registration"},
                    {"name": "puf_regeneration", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xc02", "display": "puf_regeneration (0x2)", "desc": "Puf regeneration"},
                    {"name": "puf_clear_puf_id", "flag": "hex", "default": "0xc", "action": "set_ipi_access", "offset": "0xc03", "display": "puf_clear_puf_id (0x3)", "desc": "Clear puf id"},
                    {"action": "set_ipi_access", "desc": "write set_ipi_access for PUF"},
                    {"action": "marker_end"}
                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    "pmc_em": {
      "group": "Error Management",
      "gui": "em",
      "module_rules": [
        {"name": "em_actions", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"},
            {"choice": "log", "output": 7, "display": "print to log"},
            {"choice": "sld", "output": 8, "display": "secure lockdown"},
            {"choice": "sld_io_tri", "output": 9, "display": "secure lockdown I/O tristate"},
            {"choice": "none", "output": "0xa", "display": "no action"}
          ]
        },
        {"name": "em_custom", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"},
            {"choice": "log", "output": 7, "display": "print to log"},
            {"choice": "sld", "output": 8, "display": "secure lockdown"},
            {"choice": "sld_io_tri", "output": 9, "display": "secure lockdown I/O tristate"},
            {"choice": "none", "output": "0xa", "display": "no action"},
            {"choice": "custom", "output": 3, "display": "custom"}
          ]
        },
        {"name": "em_hw", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"}
          ]
        },
        {"flag": "group", "display": "Register PMC Error 1", "desc": "https://docs.amd.com/r/en-US/am011-versal-acap-trm/System-Errors-to-PMC-EAM", "children": [
            {"flag": "group", "display": "PMC Boot Error", "children": [
                {"name": "BOOT_CR", "flag": "string", "read_only": true, "default": "none", "lsb": 0, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "BOOT_NCR", "flag": "string", "read_only": true, "default": "errout", "lsb": 1, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PLM Error", "children": [
                {"name": "FW_CR", "flag": "string", "read_only": true, "default": "errout", "lsb": 2, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "FW_NCR", "flag": "string", "default": "srst", "lsb": 3, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "General Software Error", "children": [
                {"name": "GSW_CR", "flag": "string", "default": "log", "lsb": 4, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "GSW_NCR", "flag": "string", "default": "log", "lsb": 5, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PL Config", "children": [
                {"name": "CFU", "flag": "string", "default": "none", "lsb": 6, "action": "em_set_action", "offset": "0x28100000", "display": "CFU", "choices": "em_actions"},
                {"name": "CFRAME", "flag": "string", "default": "none", "lsb": 7, "action": "em_set_action", "offset": "0x28100000", "display": "CFRAME", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PSM Error", "children": [
                {"name": "PSM_EAM_CR", "flag": "string", "default": "srst", "lsb": 8, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_hw"},
                {"name": "PSM_EAM_NCR", "flag": "string", "read_only": true, "default": "custom", "lsb": 9, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_custom"}
              ]
            },
            {"flag": "group", "display": "DDRMC MicroBlaze", "children": [
                {"name": "DDRMC_MB_CR", "flag": "string", "default": "log", "lsb": 10, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "DDRMC_MB_NCR", "flag": "string", "default": "log", "lsb": 11, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "NoC", "children": [
                {"name": "NOC_TYPE1_CR", "flag": "string", "default": "log", "lsb": 12, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "NOC_TYPE1_NCR", "flag": "string", "default": "log", "lsb": 13, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"},
                {"name": "NOC_USER", "flag": "string", "default": "none", "lsb": 14, "action": "em_set_action", "offset": "0x28100000", "display": "User", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "MMCM Lock Error. (PLL for PL)", "children": [
                {"name": "MMCM", "flag": "string", "default": "log", "lsb": 15, "action": "em_set_action", "offset": "0x28100000", "display": "MMCM", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "AI Engine", "children": [
                {"name": "AIE_CR", "flag": "string", "default": "none", "lsb": 16, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "AIE_NCR", "flag": "string", "default": "log", "lsb": 17, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "DDRMC", "children": [
                {"name": "DDRMC_MC_CR", "flag": "string", "default": "log", "lsb": 18, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "DDRMC_MC_NCR", "flag": "string", "default": "log", "lsb": 19, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "GT", "children": [
                {"name": "GT_CR", "flag": "string", "default": "none", "lsb": 20, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "GT_NCR", "flag": "string", "default": "none", "lsb": 21, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PL Sysmon", "children": [
                {"name": "PL_SMON_CR", "flag": "string", "default": "log", "lsb": 22, "action": "em_set_action", "offset": "0x28100000", "display": "CR", "choices": "em_actions"},
                {"name": "PL_SMON_NCR", "flag": "string", "default": "log", "lsb": 23, "action": "em_set_action", "offset": "0x28100000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "User defined PL Errors", "children": [
                {"name": "PL0", "flag": "string", "default": "none", "lsb": 24, "action": "em_set_action", "offset": "0x28100000", "display": "PL0", "choices": "em_actions"},
                {"name": "PL1", "flag": "string", "default": "none", "lsb": 25, "action": "em_set_action", "offset": "0x28100000", "display": "PL1", "choices": "em_actions"},
                {"name": "PL2", "flag": "string", "default": "none", "lsb": 26, "action": "em_set_action", "offset": "0x28100000", "display": "PL2", "choices": "em_actions"},
                {"name": "PL3", "flag": "string", "default": "none", "lsb": 27, "action": "em_set_action", "offset": "0x28100000", "display": "PL3", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "NPI Root Error", "children": [
                {"name": "NPI_ROOT", "flag": "string", "default": "none", "lsb": 28, "action": "em_set_action", "offset": "0x28100000", "display": "NPI_ROOT", "choices": "em_actions"}
              ]
            }
          ]
        },
        {"flag": "group", "display": "Register PMC Error 2", "desc": "https://docs.amd.com/r/en-US/am011-versal-acap-trm/System-Errors-to-PMC-EAM", "children": [
            {"flag": "group", "display": "PMC", "children": [
                {"name": "PMC_APB", "flag": "string", "default": "none", "lsb": 0, "action": "em_set_action", "offset": "0x28104000", "display": "APB", "choices": "em_actions"},
                {"name": "PMC_ROM", "flag": "string", "read_only": true, "default": "none", "lsb": 1, "action": "em_set_action", "offset": "0x28104000", "display": "BootROM", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "RCU/PPU fatal errors", "children": [
                {"name": "MB_FATAL0", "flag": "string", "read_only": true, "default": "none", "lsb": 2, "action": "em_set_action", "offset": "0x28104000", "display": "RCU", "choices": "em_actions"},
                {"name": "MB_FATAL1", "flag": "string", "read_only": true, "default": "none", "lsb": 3, "action": "em_set_action", "offset": "0x28104000", "display": "PPU", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PMC", "children": [
                {"name": "PMC_PARITY", "flag": "string", "default": "log", "lsb": 4, "action": "em_set_action", "offset": "0x28104000", "display": "parity", "choices": "em_actions"},
                {"name": "PMC_CR", "flag": "string", "default": "log", "lsb": 5, "action": "em_set_action", "offset": "0x28104000", "display": "CR", "choices": "em_actions"},
                {"name": "PMC_NCR", "flag": "string", "default": "log", "lsb": 6, "action": "em_set_action", "offset": "0x28104000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PMC SYSMON alarms", "children": [
                {"name": "PMC_SMON0", "flag": "string", "default": "log", "lsb": 7, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON0", "choices": "em_actions"},
                {"name": "PMC_SMON1", "flag": "string", "default": "log", "lsb": 8, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON1", "choices": "em_actions"},
                {"name": "PMC_SMON2", "flag": "string", "default": "log", "lsb": 9, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON2", "choices": "em_actions"},
                {"name": "PMC_SMON3", "flag": "string", "default": "log", "lsb": 10, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON3", "choices": "em_actions"},
                {"name": "PMC_SMON4", "flag": "string", "default": "log", "lsb": 11, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON4", "choices": "em_actions"},
                {"name": "PMC_SMON8", "flag": "string", "default": "none", "lsb": 15, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON8", "choices": "em_actions"},
                {"name": "PMC_SMON9", "flag": "string", "default": "log", "lsb": 16, "action": "em_set_action", "offset": "0x28104000", "display": "SYSMON9", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "CFrame", "children": [
                {"name": "CFI", "flag": "string", "default": "none", "lsb": 17, "action": "em_set_action", "offset": "0x28104000", "display": "CFI", "choices": "em_actions"},
                {"name": "CFRAME_SEU_CRC", "flag": "string", "default": "none", "lsb": 18, "action": "em_set_action", "offset": "0x28104000", "display": "CRC", "choices": "em_actions"},
                {"name": "CFRAME_SEU_ECC", "flag": "string", "default": "none", "lsb": 19, "action": "em_set_action", "offset": "0x28104000", "display": "ECC", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "Real Time Clock", "children": [
                {"name": "RTC_ALARM", "flag": "string", "default": "none", "lsb": 22, "action": "em_set_action", "offset": "0x28104000", "display": "RTC", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PLL Lock and Clock", "children": [
                {"name": "NPLL", "flag": "string", "default": "none", "lsb": 23, "action": "em_set_action", "offset": "0x28104000", "display": "NPLL", "choices": "em_actions"},
                {"name": "PPLL", "flag": "string", "default": "none", "lsb": 24, "action": "em_set_action", "offset": "0x28104000", "display": "PLL", "choices": "em_actions"},
                {"name": "CLK_MON", "flag": "string", "default": "log", "lsb": 25, "action": "em_set_action", "offset": "0x28104000", "display": "CLK_MON", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PMC Timeout", "children": [
                {"name": "PMC_TO", "flag": "string", "default": "log", "lsb": 26, "action": "em_set_action", "offset": "0x28104000", "display": "TO", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PMC XMPU/XPPU", "children": [
                {"name": "PMC_XMPU", "flag": "string", "default": "custom", "lsb": 27, "action": "em_set_action", "offset": "0x28104000", "display": "XMPU", "choices": "em_custom"},
                {"name": "PMC_XPPU", "flag": "string", "default": "custom", "lsb": 28, "action": "em_set_action", "offset": "0x28104000", "display": "XPPU", "choices": "em_custom"}
              ]
            }
          ]
        }
      ]
    },
    "psm_em": {
      "group": "Error Management",
      "gui": "em",
      "module_rules": [
        {"name": "em_actions", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"},
            {"choice": "log", "output": 7, "display": "print to log"},
            {"choice": "sld", "output": 8, "display": "secure lockdown"},
            {"choice": "sld_io_tri", "output": 9, "display": "secure lockdown I/O tristate"},
            {"choice": "none", "output": "0xa", "display": "no action"}
          ]
        },
        {"name": "em_custom", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"},
            {"choice": "log", "output": 7, "display": "print to log"},
            {"choice": "sld", "output": 8, "display": "secure lockdown"},
            {"choice": "sld_io_tri", "output": 9, "display": "secure lockdown I/O tristate"},
            {"choice": "none", "output": "0xa", "display": "no action"},
            {"choice": "custom", "output": 3, "display": "custom"}
          ]
        },
        {"flag": "group", "display": "Register PSM Error 1", "desc": "https://docs.amd.com/r/en-US/am011-versal-acap-trm/System-Errors-to-PSM-EAM", "children": [
            {"flag": "group", "display": "PS Software", "children": [
                {"name": "PS_SW_CR", "flag": "string", "default": "log", "lsb": 0, "action": "em_set_action", "offset": "0x28108000", "display": "CR", "choices": "em_actions"},
                {"name": "PS_SW_NCR", "flag": "string", "default": "log", "lsb": 1, "action": "em_set_action", "offset": "0x28108000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PSM Firmware", "children": [
                {"name": "PSM_B_CR", "flag": "string", "default": "log", "lsb": 2, "action": "em_set_action", "offset": "0x28108000", "display": "CR", "choices": "em_actions"},
                {"name": "PSM_B_NCR", "flag": "string", "default": "log", "lsb": 3, "action": "em_set_action", "offset": "0x28108000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "MicroBlaze Fatal", "children": [
                {"name": "MB_FATAL", "flag": "string", "default": "log", "lsb": 4, "action": "em_set_action", "offset": "0x28108000", "display": "MB", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PSM", "children": [
                {"name": "PSM_CR", "flag": "string", "default": "log", "lsb": 5, "action": "em_set_action", "offset": "0x28108000", "display": "CR", "choices": "em_actions"},
                {"name": "PSM_NCR", "flag": "string", "default": "log", "lsb": 6, "action": "em_set_action", "offset": "0x28108000", "display": "NCR", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "ECC", "children": [
                {"name": "OCM_ECC", "flag": "string", "default": "log", "lsb": 7, "action": "em_set_action", "offset": "0x28108000", "display": "OCM", "choices": "em_actions"},
                {"name": "L2_ECC", "flag": "string", "default": "log", "lsb": 8, "action": "em_set_action", "offset": "0x28108000", "display": "L2", "choices": "em_actions"},
                {"name": "RPU_ECC", "flag": "string", "default": "log", "lsb": 9, "action": "em_set_action", "offset": "0x28108000", "display": "RPU", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "RPU", "children": [
                {"name": "RPU_LS", "flag": "string", "default": "log", "lsb": 10, "action": "em_set_action", "offset": "0x28108000", "display": "RPU_LS", "choices": "em_actions"},
                {"name": "RPU_CCF", "flag": "string", "default": "log", "lsb": 11, "action": "em_set_action", "offset": "0x28108000", "display": "RPU_CCF", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "Lock Error", "children": [
                {"name": "APLL_LOCK", "flag": "string", "default": "none", "lsb": 14, "action": "em_set_action", "offset": "0x28108000", "display": "APLL", "choices": "em_actions"},
                {"name": "RPLL_LOCK", "flag": "string", "default": "none", "lsb": 15, "action": "em_set_action", "offset": "0x28108000", "display": "RPLL", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "GIC", "children": [
                {"name": "GIC_AXI", "flag": "string", "default": "log", "lsb": 12, "action": "em_set_action", "offset": "0x28108000", "display": "AXI", "choices": "em_actions"},
                {"name": "GIC_ECC", "flag": "string", "default": "log", "lsb": 13, "action": "em_set_action", "offset": "0x28108000", "display": "ECC", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "CPM", "children": [
                {"name": "CPM_CR", "flag": "string", "default": "log", "lsb": 16, "action": "em_set_action", "offset": "0x28108000", "display": "CR", "choices": "em_actions"},
                {"name": "CPM_NCR", "flag": "string", "read_only": true, "default": "custom", "lsb": 17, "action": "em_set_action", "offset": "0x28108000", "display": "NCR", "choices": "em_custom"}
              ]
            },
            {"flag": "group", "display": "APB errors", "children": [
                {"name": "LPD_APB", "flag": "string", "default": "log", "lsb": 18, "action": "em_set_action", "offset": "0x28108000", "display": "LPD", "choices": "em_actions"},
                {"name": "FPD_APB", "flag": "string", "default": "log", "lsb": 19, "action": "em_set_action", "offset": "0x28108000", "display": "FPD", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "Parity", "children": [
                {"name": "LPD_PAR", "flag": "string", "default": "log", "lsb": 20, "action": "em_set_action", "offset": "0x28108000", "display": "LPD", "choices": "em_actions"},
                {"name": "FPD_PAR", "flag": "string", "default": "log", "lsb": 21, "action": "em_set_action", "offset": "0x28108000", "display": "FPD", "choices": "em_actions"},
                {"name": "IOU_PAR", "flag": "string", "default": "log", "lsb": 22, "action": "em_set_action", "offset": "0x28108000", "display": "IOU", "choices": "em_actions"},
                {"name": "PSM_PAR", "flag": "string", "default": "log", "lsb": 23, "action": "em_set_action", "offset": "0x28108000", "display": "PSM", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "Interconnect Timout", "children": [
                {"name": "LPD_TO", "flag": "string", "default": "log", "lsb": 24, "action": "em_set_action", "offset": "0x28108000", "display": "LPD", "choices": "em_actions"},
                {"name": "FPD_TO", "flag": "string", "default": "log", "lsb": 25, "action": "em_set_action", "offset": "0x28108000", "display": "FPD", "choices": "em_actions"},
                {"name": "PSM_TO", "flag": "string", "default": "log", "lsb": 26, "action": "em_set_action", "offset": "0x28108000", "display": "PSM", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "XRAM", "children": [
                {"name": "XRAM_CR", "flag": "string", "default": "log", "lsb": 27, "action": "em_set_action", "offset": "0x28108000", "display": "CR", "choices": "em_actions"},
                {"name": "XRAM_NCR", "flag": "string", "default": "log", "lsb": 28, "action": "em_set_action", "offset": "0x28108000", "display": "NCR", "choices": "em_actions"}
              ]
            }
          ]
        },
        {"flag": "group", "display": "Register PSM Error 2", "desc": "https://docs.amd.com/r/en-US/am011-versal-acap-trm/System-Errors-to-PSM-EAM", "children": [
            {"flag": "group", "display": "Watchdog Timer", "children": [
                {"name": "LPD_SWDT", "flag": "string", "default": "log", "lsb": 0, "action": "em_set_action", "offset": "0x2810c000", "display": "LPD", "choices": "em_actions"},
                {"name": "FPD_SWDT", "flag": "string", "default": "log", "lsb": 1, "action": "em_set_action", "offset": "0x2810c000", "display": "FPD", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "XMPU/XPPU", "children": [
                {"name": "LPD_XMPU", "flag": "string", "default": "custom", "lsb": 18, "action": "em_set_action", "offset": "0x2810c000", "display": "LPD_XMPU", "choices": "em_custom"},
                {"name": "LPD_XPPU", "flag": "string", "default": "custom", "lsb": 19, "action": "em_set_action", "offset": "0x2810c000", "display": "LPD_XPPU", "choices": "em_custom"},
                {"name": "FPD_XMPU", "flag": "string", "default": "custom", "lsb": 20, "action": "em_set_action", "offset": "0x2810c000", "display": "FPD_XMPU", "choices": "em_custom"}
              ]
            }
          ]
        }
      ]
    },
    "sw_em": {
      "group": "Error Management",
      "gui": "em",
      "module_rules": [
        {"name": "em_actions", "flag": "string", "hide": true, "desc": "choice definitions", "choices": [
            {"choice": "por", "output": 1, "display": "power-on reset"},
            {"choice": "srst", "output": 2, "display": "system reset"},
            {"choice": "errout", "output": 4, "display": "error out"},
            {"choice": "log", "output": 7, "display": "print to log"},
            {"choice": "sld", "output": 8, "display": "secure lockdown"},
            {"choice": "sld_io_tri", "output": 9, "display": "secure lockdown I/O tristate"},
            {"choice": "none", "output": "0xa", "display": "no action"}
          ]
        },
        {"flag": "group", "display": "SW Errors", "children": [
            {"flag": "group", "display": "Health Boot Monitoring", "children": [
                {"name": "HB_MON_0", "flag": "string", "default": "none", "lsb": 0, "action": "em_set_action", "offset": "0x28110000", "display": "HB0", "choices": "em_actions"},
                {"name": "HB_MON_1", "flag": "string", "default": "none", "lsb": 1, "action": "em_set_action", "offset": "0x28110000", "display": "HB1", "choices": "em_actions"},
                {"name": "HB_MON_2", "flag": "string", "default": "none", "lsb": 2, "action": "em_set_action", "offset": "0x28110000", "display": "HB2", "choices": "em_actions"},
                {"name": "HB_MON_3", "flag": "string", "default": "none", "lsb": 3, "action": "em_set_action", "offset": "0x28110000", "display": "HB3", "choices": "em_actions"},
                {"name": "HB_MON_4", "flag": "string", "default": "none", "lsb": 10, "action": "em_set_action", "offset": "0x28110000", "display": "HB4", "choices": "em_actions"},
                {"name": "HB_MON_5", "flag": "string", "default": "none", "lsb": 11, "action": "em_set_action", "offset": "0x28110000", "display": "HB5", "choices": "em_actions"},
                {"name": "HB_MON_6", "flag": "string", "default": "none", "lsb": 12, "action": "em_set_action", "offset": "0x28110000", "display": "HB6", "choices": "em_actions"},
                {"name": "HB_MON_7", "flag": "string", "default": "none", "lsb": 13, "action": "em_set_action", "offset": "0x28110000", "display": "HB7", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "PLM Exception during run time", "children": [
                {"name": "PLM_EXCEPTION", "flag": "string", "default": "none", "lsb": 4, "action": "em_set_action", "offset": "0x28110000", "display": "PLM", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "ERROR_CRAM", "children": [
                {"name": "ERROR_CRAM_CE", "flag": "string", "default": "none", "lsb": 5, "action": "em_set_action", "offset": "0x28110000", "display": "CRAM_CE", "choices": "em_actions"},
                {"name": "ERROR_CRAM_UE", "flag": "string", "default": "none", "lsb": 6, "action": "em_set_action", "offset": "0x28110000", "display": "CRAM_UE", "choices": "em_actions"}
              ]
            },
            {"flag": "group", "display": "ERROR_NPI_UE", "children": [
                {"name": "ERROR_NPI_UE", "flag": "string", "default": "none", "lsb": 7, "action": "em_set_action", "offset": "0x28110000", "display": "NPI_UE", "choices": "em_actions"}
              ]
            }
          ]
        }
      ]
    }
  },
  "device": {
    "sites": [
      {"name": "DDRMC_X0Y0", "config_addr": "0xf6080000", "marker": "DDRMC_XMPU_F6070000"}
    ]
  },
  "default_settings": {
    "flags": {"debugger_access": true, "enable_protection": true, "write_subsystems": true},
    "base_protection": {
      "access": [
        {
          "name": "firmware_and_cci",
          "comment": "root-access for memory, opens SMID 0 for CCI cache management",
          "type": "smid_list",
          "SMIDs": ["FPD_CCI", "PMC_DMA0", "PMC_DMA1", "RCU_and_PPU"]
        },
        {
          "name": "firmware_and_cci.debug",
          "comment": "root-access for memory, opens SMID 0 for CCI cache management",
          "type": "smid_list",
          "SMIDs": ["DAP", "FPD_CCI", "PMC_DMA_and_DPC", "RCU_and_PPU"]
        },
        {
          "name": "firmware",
          "comment": "Firmware masters, used as a masters list for protection unit root-access",
          "type": "smid_list",
          "SMIDs": ["PMC_DMA0", "PMC_DMA1", "PSM", "RCU_and_PPU"]
        },
        {
          "name": "firmware.debug",
          "comment": "Firmware masters, used for root-access if debugger_access is enabled",
          "type": "smid_list",
          "SMIDs": ["DAP", "PMC_DMA_and_DPC", "PSM", "RCU_and_PPU"]
        },
        {
          "name": "open_rw",
          "comment": "Any master can access these as read/write",
          "destinations": [
            "CoreSight",
            "IPI_buffers",
            "IPI_channels",
            "OCM_CSR",
            "RPU_DUAL_CSR",
            "USB2_XHCI"
          ],
          "SMIDs": ["ANY"]
        },
        {
          "name": "open_rw_fpd",
          "comment": "Any master can access these as read/write",
          "destinations": ["APU_DUAL_CSR", "APU_GIC", "FPD_SMMU", "FPD_SMMU_CSR", "FPD_SWDT"],
          "SMIDs": ["ANY"]
        },
        {
          "name": "open_ro",
          "comment": "Any master can access these as read-only",
          "destinations": ["CRP", "SCNTR_SECURE"],
          "flags": {"read_only": true},
          "SMIDs": ["ANY"]
        },
        {
          "name": "open_ro_2",
          "comment": "Any master can access these as read-only",
          "destinations": ["PLM_RTCA"],
          "flags": {"read_only": true},
          "SMIDs": ["ANY"]
        },
        {
          "name": "apu_rw",
          "destinations": ["FPD_CCI_CORE"],
          "SMIDs": ["APU"]
        },
        {
          "name": "bootmedia",
          "comment": "Allow booting from different boot media",
          "destinations": [
            "CFU_STREAM_mem",
            "PMC_OSPI_mem",
            "PPU",
            "PSM_DCACHE_mem",
            "PSM_ICACHE_mem",
            "RPU_Memory"
          ],
          "SMIDs": ["OSPI", "QSPI", "SD_eMMC"]
        },
        {
          "name": "bootmedia_pmc",
          "destinations": ["PMC_RAM_mem"],
          "SMIDs": ["OSPI", "QSPI", "SD_eMMC"]
        },
        {
          "name": "PLM_image_store",
          "comment": "Destination for PLM image store",
          "SMIDs": ["PMC_DMA0", "PMC_DMA1", "PSM", "RCU_and_PPU"]
        }
      ],
      "units": {
        "FPD_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "LPD_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "OCM_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"interrupt_enable": true, "lock": true}
        },
        "PMC_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XPPU_NPI": {
          "root_access": "firmware",
          "flags": {"enable": true, "interrupt_enable": true, "lock": true}
        }
      }
    },
    "subsystems": {
      "default": {
        "id": "0x0",
        "access": [
          {
            "name": "cpus",
            "type": "cpu_list",
            "SMIDs": ["APU"]
          },
          {
            "name": "secure_cpus",
            "type": "cpu_list",
            "flags": {"secure": true},
            "SMIDs": ["RPU0"]
          },
          {
            "name": "uart",
            "destinations": ["UART0", "UART1"],
            "flags": {"requested": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true}
          },
          {
            "name": "gem",
            "destinations": ["GEM0", "GEM1"],
            "flags": {"requested": true, "requested_emit_wakeup": true, "requested_full_access": true, "requested_preserve_context": true, "requested_secure": false, "secure": false, "shared": true}
          },
          {
            "name": "mem_ctrl",
            "destinations": ["DDR0"],
            "type": "ss_management",
            "flags": {"shared": true},
            "SMIDs": ["ANY"]
          },
          {
            "name": "mem",
            "destinations": ["OCM0_mem", "OCM1_mem", "OCM2_mem", "OCM3_mem"],
            "flags": {"requested": true, "requested_full_access": true, "requested_preserve_context": true, "shared": true}
          },
          {
            "name": "bootmedia",
            "destinations": ["OSPI", "QSPI", "SD_eMMC0", "SD_eMMC1"],
            "flags": {"requested": true, "requested_full_access": true, "requested_secure": false, "secure": false, "shared": true}
          },
          {
            "name": "OSPI_mem",
            "comment": "OSPI may require PMC_OSPI_mem",
            "destinations": ["PMC_OSPI_mem"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["APU", "RPU"]
          },
          {
            "name": "non_secure",
            "destinations": [
              "LPD_I2C0",
              "LPD_I2C1",
              "TTC0",
              "TTC1",
              "TTC2",
              "TTC3"
            ],
            "flags": {"requested": true, "requested_full_access": true, "shared": true}
          },
          {
            "name": "ipi0",
            "destinations": ["IPI0"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["APU"]
          },
          {
            "name": "ipi1",
            "destinations": ["IPI1"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["RPU0"]
          },
          {
            "name": "ipi2",
            "destinations": ["IPI2"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["RPU1"]
          },
          {
            "name": "ipi5",
            "destinations": ["IPI5"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["DAP_DPC_MISC"]
          },
          {
            "name": "ipi_unused",
            "destinations": ["IPI3", "IPI4", "IPI6"],
            "flags": {"requested": true, "requested_full_access": true},
            "SMIDs": ["UNUSED"]
          },
          {
            "name": "resets",
            "destinations": [
              "RST_NOC",
              "RST_NOC_POR",
              "RST_NPI",
              "RST_PL0",
              "RST_PL1",
              "RST_PL2",
              "RST_PL3",
              "RST_PL_POR",
              "RST_PL_SRST",
              "RST_PMC",
              "RST_PMC_POR",
              "RST_SYS_RST_1",
              "RST_SYS_RST_2",
              "RST_SYS_RST_3"
            ],
            "type": "ss_management"
          },
          {
            "name": "not_requested_secure",
            "destinations": ["USB2_CSR"],
            "flags": {"secure": false, "shared": true}
          },
          {
            "name": "ggs_pggs",
            "destinations": [
              "GGS0",
              "GGS1",
              "GGS2",
              "GGS3",
              "PGGS0",
              "PGGS1"
            ],
            "type": "ss_management"
          },
          {
            "name": "not_requested_mgr",
            "destinations": [
              "LPD_DMA_CH0",
              "LPD_DMA_CH1",
              "LPD_DMA_CH2",
              "LPD_DMA_CH3",
              "LPD_DMA_CH4",
              "LPD_DMA_CH5",
              "LPD_DMA_CH6",
              "LPD_DMA_CH7",
              "PMC_SYSMON_CSR"
            ],
            "flags": {"shared": true}
          },
          {
            "name": "not_requested_fpd",
            "destinations": ["FPD_SWDT"],
            "flags": {"shared": true}
          },
          {
            "name": "not_requested_mem",
            "destinations": ["RPU0_TCMA_mem", "RPU0_TCMB_mem", "RPU1_TCMA_mem_dual", "RPU1_TCMB_mem_dual"],
            "flags": {"shared": true}
          },
          {
            "name": "not_requested",
            "destinations": [
              "CANFD0",
              "CANFD1",
              "LPD_GPIO",
              "LPD_SWDT",
              "PMC_EFUSE_CACHE",
              "PMC_GPIO",
              "PMC_I2C",
              "PMC_RTC",
              "SPI0",
              "SPI1",
              "XRAM0_0_mem",
              "XRAM0_1_mem",
              "XRAM0_2_mem",
              "XRAM0_3_mem",
              "XRAM1_0_mem",
              "XRAM1_1_mem",
              "XRAM1_2_mem",
              "XRAM1_3_mem",
              "XRAM2_0_mem",
              "XRAM2_1_mem",
              "XRAM2_2_mem",
              "XRAM2_3_mem",
              "XRAM3_0_mem",
              "XRAM3_1_mem",
              "XRAM3_2_mem",
              "XRAM3_3_mem"
            ],
            "flags": {"shared": true}
          }
        ]
      }
    }
  },
  "design": {
    "name": "ve2302_pcie_xdma_secure",
    "destinations": [
      {"name": "ddr_reg_0", "comment": "ns_strict", "addr": "0x0", "size": "864M", "mem": true, "nodeid": "0x18900000"},
      {"name": "ddr_reg_1", "comment": "ns_shared", "addr": "0x36000000", "size": "16M", "mem": true, "nodeid": "0x18900001"},
      {"name": "ddr_reg_2", "comment": "ns_shared", "addr": "0x37000000", "size": "16M", "mem": true, "nodeid": "0x18900002"},
      {"name": "ddr_reg_3", "comment": "secure_shared", "addr": "0x38000000", "size": "128M", "mem": true, "nodeid": "0x18900003"},
      {"name": "ddr_reg_4", "comment": "secure", "addr": "0x40000000", "size": "512M", "mem": true, "nodeid": "0x18900004"},
      {"name": "ddr_reg_5", "comment": "ns_shared", "addr": "0x60000000", "size": "512M", "mem": true, "nodeid": "0x18900005"},
      {"name": "ddr_reg_6", "comment": "secure", "addr": "0x50000000000", "size": "8G", "mem": true, "nodeid": "0x18900009"}
    ],
    "cells": {
      "blp": {
        "type": "hier",
        "cells": {
          "axi_noc_ic": {
            "type": "noc",
            "SMIDs": [
              {"ref": "S06_AXI", "netlist_name": "inst/S06_AXI_nmu", "value": "0x10", "count": 1},
              {"ref": "S07_AXI", "netlist_name": "inst/S07_AXI_nmu", "value": "0x11", "count": 1},
              {"ref": "S08_AXI", "netlist_name": "inst/S08_AXI_nmu", "value": "0x12", "count": 1}
            ]
          },
          "axi_noc_mc_1x": {
            "type": "noc",
            "XMPUs": [
              {
                "name": "ddrmc",
                "module": "ddr4_xmpu",
                "addrs": [
                  {"addr": "0x0", "size": "2G"},
                  {"addr": "0x50000000000", "size": "512G"}
                ],
                "sites": ["DDRMC_X0Y0"]
              }
            ],
            "destinations": [
              {"name": "DDR_LOW0", "addr": "0x0", "size": "2G", "mem": true},
              {"name": "DDR_CH1", "addr": "0x50000000000", "size": "6G", "mem": true}
            ]
          },
          "cips": {
            "type": "ps",
            "units": [
              {"name": "PLM", "display": "PLM", "module": "plm", "config_addr": "0xf2014000", "marker": "PMC_FW_CONFIG", "constants": {"no_marker": true}},
              {"name": "LPD_INT_CSR", "display": "LPD_INT_CSR Coherency", "module": "INTLPD_CONFIG", "config_addr": "0xfe600000", "marker": "LPD_DATA/INTLPD_CONFIG", "constants": {"codeModule": "coherent"}},
              {"name": "LPD_IOP_SLCR", "display": "LPD_IOP_SLCR Coherency", "module": "lpd_iou_slcr", "config_addr": "0xff080000", "marker": "LPD_DATA/IOU_SLCR", "constants": {"codeModule": "coherent"}},
              {"name": "IPI", "display": "IPI Channels", "module": "ipi", "config_addr": "0xff300000", "marker": "IPI"},
              {"name": "LPD_SLCR", "display": "LPD SLCR", "module": "lpd_slcr", "config_addr": "0xff410000", "constants": {"no_marker": true}},
              {"name": "IPI_PERM", "display": "PLM Commands", "module": "ipi_perm", "perSLR": true, "marker": "PMC_FW_CONFIG", "constants": {"no_marker": true, "slr_module": "ipi_perm_slr"}},
              {"name": "NOC_NMU", "display": "NOC NMU SMIDs", "module": "noc_nmu", "marker": "NPI_PRE_STARTUP/NOC_NMU"},
              {"name": "PMC_EM", "display": "PMC Errors", "module": "pmc_em", "marker": "PMC_EM"},
              {"name": "PSM_EM", "display": "PSM Errors", "module": "psm_em", "marker": "LPD_FINISH/EM"},
              {"name": "SW_EM", "display": "Software Errors", "module": "sw_em", "marker": "PMC_EM/software"}
            ],
            "XPPUs": [
              {"name": "PMC_XPPU_NPI", "module": "xppu", "config_addr": "0xf1300000", "constants": {"power_domain": "PMC", "power_node_id": "0x4208001"}},
              {"name": "PMC_XPPU", "module": "xppu", "config_addr": "0xf1310000", "constants": {"power_domain": "PMC", "power_node_id": "0x4208001"}},
              {"name": "LPD_XPPU", "module": "xppu", "config_addr": "0xff990000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}}
            ],
            "XPPU_apertures": [
              {"base": "0xf1000000", "XPPU": "PMC_XPPU", "apertureSize": "64K", "apertureCount": 256, "apertureStartIndex": 0, "name": "PMC_XPPU_64KB_apertures"},
              {"base": "0xf6000000", "XPPU": "PMC_XPPU_NPI", "apertureSize": "64K", "apertureCount": 256, "apertureStartIndex": 0, "name": "PMC_XPPU_NPI_64KB_apertures"},
              {"base": "0xff000000", "XPPU": "LPD_XPPU", "apertureSize": "64K", "apertureCount": 240, "apertureStartIndex": 0, "name": "LPD_XPPU_64KB_apertures"},
              {"base": "0xf0000000", "XPPU": "PMC_XPPU", "apertureSize": "1M", "apertureCount": 16, "apertureStartIndex": 384, "name": "PMC_XPPU_1MB_apertures"},
              {"base": "0xf7000000", "XPPU": "PMC_XPPU_NPI", "apertureSize": "1M", "apertureCount": 16, "apertureStartIndex": 384, "name": "PMC_XPPU_NPI_1MB_apertures"},
              {"base": "0xfe000000", "XPPU": "LPD_XPPU", "apertureSize": "1M", "apertureCount": 16, "apertureStartIndex": 384, "name": "LPD_XPPU_1MB_apertures"},
              {"base": "0xc0000000", "XPPU": "PMC_XPPU", "apertureSize": "512M", "apertureCount": 1, "apertureStartIndex": 400, "name": "PMC_XPPU_512MB_aperture"},
              {"base": "0xfc000000", "XPPU": "LPD_XPPU", "apertureSize": "16M", "apertureCount": 1, "apertureStartIndex": 400, "name": "LPD_XPPU_512MB_aperture"}
            ],
            "XMPUs": [
              {"name": "SECURE_REG_ACCESS", "module": "secure_reg_access", "config_addr": "0x1", "marker": "SUBSYSTEM_DEFINITION/USERDEF/REG_ACCESS"},
              {"name": "PMC_XMPU", "module": "xmpu", "config_addr": "0xf12f0000", "constants": {"do_not_optimize": true, "power_domain": "PMC", "power_node_id": "0x4208001"}},
              {"name": "FPD_XMPU", "module": "xmpu", "config_addr": "0xfd390000", "constants": {"power_domain": "FPD", "power_node_id": "0x420c003"}},
              {"name": "XRAM_XMPU0", "module": "xmpu", "config_addr": "0xff930000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}},
              {"name": "XRAM_XMPU1", "module": "xmpu", "config_addr": "0xff934000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}},
              {"name": "XRAM_XMPU2", "module": "xmpu", "config_addr": "0xff938000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}},
              {"name": "XRAM_XMPU3", "module": "xmpu", "config_addr": "0xff93c000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}},
              {"name": "OCM_XMPU", "module": "xmpu", "config_addr": "0xff980000", "constants": {"power_domain": "LPD", "power_node_id": "0x4210002"}}
            ],
            "SMIDs": [
              {"name": "ANY", "comment": "Matches all SMIDs", "value": "0x0", "count": 1024},
              {"name": "PL_AIE_CPM", "value": "0x0", "count": 512},
              {"name": "PL_AIE", "value": "0x0", "count": 256, "altname": "PL"},
              {"name": "FPD_CCI", "comment": "Issued by CCI-500 cache management", "value": "0x0"},
              {"name": "AIE", "value": "0xf0", "count": 16},
              {"name": "CIPS", "value": "0x200", "count": 128},
              {"name": "LPD", "value": "0x200", "count": 64},
              {"name": "RPU", "value": "0x200", "count": 8, "cpu": true, "type": "rpu"},
              {"name": "RPU0", "value": "0x200", "count": 4, "cpu": true, "type": "rpu", "nodeid": "0x18110005"},
              {"name": "RPU1", "value": "0x204", "count": 4, "cpu": true, "type": "rpu", "nodeid": "0x18110006"},
              {"name": "LPD_DMA_CH", "value": "0x210", "count": 16},
              {"name": "LPD_DMA_CH0", "value": "0x210", "count": 2},
              {"name": "LPD_DMA_CH1", "value": "0x212", "count": 2},
              {"name": "LPD_DMA_CH2", "value": "0x214", "count": 2},
              {"name": "LPD_DMA_CH3", "value": "0x216", "count": 2},
              {"name": "LPD_DMA_CH4", "value": "0x218", "count": 2},
              {"name": "LPD_DMA_CH5", "value": "0x21a", "count": 2},
              {"name": "LPD_DMA_CH6", "value": "0x21c", "count": 2},
              {"name": "LPD_DMA_CH7", "value": "0x21e", "count": 2},
              {"name": "USB2", "value": "0x230", "count": 2},
              {"name": "GEM", "value": "0x234", "count": 2},
              {"name": "GEM0", "value": "0x234", "count": 1},
              {"name": "GEM1", "value": "0x235", "count": 1},
              {"name": "PSM_and_DPC_DMA", "comment": "includes: PSM; DPC_DMA", "value": "0x238", "count": 2},
              {"name": "PSM", "value": "0x238", "count": 1},
              {"name": "DPC_DMA", "value": "0x239", "count": 1},
              {"name": "PMC", "value": "0x240", "count": 16},
              {"name": "DAP_DPC_MISC", "comment": "IPI assignment for DAP; DPC & Miscellaneous (PMC_SYSMON & PMC_DMA0)", "value": "0x240", "mask_n": "0x9", "altname": "DAP_and_DPC"},
              {"name": "DAP", "value": "0x240", "count": 1},
              {"name": "PMC_SYSMON", "value": "0x241", "count": 1},
              {"name": "SD_eMMC", "value": "0x242", "count": 2},
              {"name": "SD_eMMC0", "value": "0x242", "count": 1},
              {"name": "SD_eMMC1", "value": "0x243", "count": 1},
              {"name": "QSPI", "value": "0x244", "count": 1},
              {"name": "OSPI", "value": "0x245", "count": 1},
              {"name": "RCU_and_PPU", "value": "0x246", "count": 2},
              {"name": "RCU", "comment": "ROM Code Unit", "value": "0x246", "count": 1, "cpu": true},
              {"name": "PPU", "value": "0x247", "count": 1},
              {"name": "PMC_DMA_and_DPC", "comment": "includes: PMC_DMA0; DPC; unused SMID 0x24A; PMC_DMA1", "value": "0x248", "count": 4},
              {"name": "PMC_DMA0", "value": "0x248", "count": 1},
              {"name": "DPC", "value": "0x249", "count": 1},
              {"name": "PMC_DMA1", "value": "0x24b", "count": 1},
              {"name": "PCIe", "value": "0x250", "count": 8},
              {"name": "APU", "comment": "APU bits 3:0 are determined by the AXI_ID", "value": "0x260", "count": 16, "cpu": true, "type": "apu"},
              {"name": "APU0", "comment": "APU0 & 1 have the same SMIDs but can specify which core is used in a subsystem", "value": "0x260", "count": 16, "cpu": true, "type": "apu", "nodeid": "0x1810c003"},
              {"name": "APU1", "value": "0x260", "count": 16, "cpu": true, "type": "apu", "nodeid": "0x1810c004"},
              {"name": "APU_GIC", "value": "0x272", "count": 1},
              {"name": "DEBUG", "comment": "CoreSight", "value": "0x273", "count": 1},
              {"name": "FPD_SMMU", "value": "0x274", "count": 1},
              {"name": "UNUSED", "comment": "Unused SMID used for IPI channels", "value": "0x3ff", "altname": "NONE"}
            ],
            "destinations": [
              {"name": "DDR0", "addr": "0x0", "size": "0", "nodeid": "0x18320010", "desc": "Used by PLM to manage DDR. Not DDR memory and not the memory controller"},
              {"name": "GGS0", "addr": "0x0", "size": "0", "nodeid": "0x18248000", "type": "general_storage", "desc": "Global General Storage"},
              {"name": "GGS1", "addr": "0x0", "size": "0", "nodeid": "0x18248001", "type": "general_storage", "desc": "Global General Storage"},
              {"name": "GGS2", "addr": "0x0", "size": "0", "nodeid": "0x18248002", "type": "general_storage", "desc": "Global General Storage"},
              {"name": "GGS3", "addr": "0x0", "size": "0", "nodeid": "0x18248003", "type": "general_storage", "desc": "Global General Storage"},
              {"name": "HB_MON0", "addr": "0x0", "size": "0", "nodeid": "0x18250000", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON1", "addr": "0x0", "size": "0", "nodeid": "0x18250001", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON2", "addr": "0x0", "size": "0", "nodeid": "0x18250002", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON3", "addr": "0x0", "size": "0", "nodeid": "0x18250003", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON4", "addr": "0x0", "size": "0", "nodeid": "0x18250004", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON5", "addr": "0x0", "size": "0", "nodeid": "0x18250005", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON6", "addr": "0x0", "size": "0", "nodeid": "0x18250006", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "HB_MON7", "addr": "0x0", "size": "0", "nodeid": "0x18250007", "type": "healthy_boot_monitor", "desc": "Healthy Boot Monitor"},
              {"name": "PGGS0", "addr": "0x0", "size": "0", "nodeid": "0x1824c004", "type": "general_storage", "desc": "Persistent Global General Storage"},
              {"name": "PGGS1", "addr": "0x0", "size": "0", "nodeid": "0x1824c005", "type": "general_storage", "desc": "Persistent Global General Storage"},
              {"name": "RST_NOC", "addr": "0x0", "size": "0", "nodeid": "0xc41000c", "type": "reset", "desc": "Reset"},
              {"name": "RST_NOC_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c005", "type": "reset", "desc": "Reset"},
              {"name": "RST_NPI", "addr": "0x0", "size": "0", "nodeid": "0xc41000d", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL0", "addr": "0x0", "size": "0", "nodeid": "0xc410012", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL1", "addr": "0x0", "size": "0", "nodeid": "0xc410013", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL2", "addr": "0x0", "size": "0", "nodeid": "0xc410014", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL3", "addr": "0x0", "size": "0", "nodeid": "0xc410015", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c004", "type": "reset", "desc": "Reset"},
              {"name": "RST_PL_SRST", "addr": "0x0", "size": "0", "nodeid": "0xc41000b", "type": "reset", "desc": "Reset"},
              {"name": "RST_PMC", "addr": "0x0", "size": "0", "nodeid": "0xc410002", "type": "reset", "desc": "Reset"},
              {"name": "RST_PMC_POR", "addr": "0x0", "size": "0", "nodeid": "0xc30c001", "type": "reset", "desc": "Reset"},
              {"name": "RST_SYS_RST_1", "addr": "0x0", "size": "0", "nodeid": "0xc41000e", "type": "reset", "desc": "Reset"},
              {"name": "RST_SYS_RST_2", "addr": "0x0", "size": "0", "nodeid": "0xc41000f", "type": "reset", "desc": "Reset"},
              {"name": "RST_SYS_RST_3", "addr": "0x0", "size": "0", "nodeid": "0xc410010", "type": "reset", "desc": "Reset"},
              {"name": "LPD_AXI_PL_mem", "addr": "0x80000000", "size": "512M", "mem": true, "desc": "PS-to-PL AXI Interface from LPD", "constants": {"pl": true}},
              {"name": "FPD_AXI_PL_L0_mem", "addr": "0xa4000000", "size": "192M", "mem": true, "desc": "PS-to-PL AXI Interface from FPD; lower", "constants": {"pl": true}},
              {"name": "FPD_AXI_PL_L1_mem", "addr": "0xb0000000", "size": "256M", "mem": true, "desc": "PS-to-PL AXI Interface from FPD; upper", "constants": {"pl": true}},
              {"name": "PMC_OSPI_mem", "addr": "0xc0000000", "size": "512M", "mem": true, "nodeid": "0x18900006", "desc": "Octal-SPI Linear Mode memory space"},
              {"name": "PMC", "addr": "0xf0000000", "size": "128M"},
              {"name": "PMC_XPPU_1MB_apertures", "addr": "0xf0000000", "size": "16M"},
              {"name": "PPU", "addr": "0xf0200000", "size": "1M"},
              {"name": "PPU_RAM_INSTR_mem", "addr": "0xf0200000", "size": "256K", "mem": true, "desc": "PPU I-cache Addressable"},
              {"name": "PPU_RAM_DATA_mem", "addr": "0xf0240000", "size": "128K", "mem": true, "desc": "PPU D-cache Addressable"},
              {"name": "PPU_IOMODULE", "addr": "0xf0280000", "size": "4K", "altname": "PPU1_IOMODULE", "desc": "PPU I/O Module registers"},
              {"name": "PPU_ICACHE_CTRL", "addr": "0xf0281000", "size": "4K", "altname": "PPU1_RAM_INSTR_ECC_CTRL", "desc": "PPU Instruction Cache ECC control"},
              {"name": "PPU_DCACHE_CTRL", "addr": "0xf0282000", "size": "4K", "altname": "PPU1_RAM_DATA_ECC_CTRL", "desc": "PPU Data Cache ECC control"},
              {"name": "PPU_TMR_MANAGER", "addr": "0xf0283000", "size": "4K", "altname": "PPU1_TMR_MANAGER", "desc": "PPU Triple Redundancy Manager"},
              {"name": "PPU_TMR_INJECT", "addr": "0xf0284000", "size": "4K", "altname": "PPU1_TMR_INJECT", "desc": "PPU Triple Redundancy Error Injection"},
              {"name": "PPU_DEBUG", "addr": "0xf0300000", "size": "1M"},
              {"name": "PPU_TMR_TRACE", "addr": "0xf0300000", "size": "4K", "altname": "PPU1_TMR_TRACE", "desc": "PPU Trace"},
              {"name": "PPU_MDM", "addr": "0xf0310000", "size": "32K", "altname": "PPU1_MDM_HSD", "desc": "PPU Debug Module control"},
              {"name": "CoreSight", "addr": "0xf0800000", "size": "8M"},
              {"name": "DBG_PMC", "addr": "0xf0800000", "size": "1M"},
              {"name": "DBG_PMC_ROM", "addr": "0xf0800000", "size": "64K", "altname": "CoreSight_PMC_ROM", "desc": "CoreSight PMC ROM"},
              {"name": "DBG_PMC_GPR", "addr": "0xf0810000", "size": "64K", "altname": "CoreSight_PMC_GPR", "desc": "CoreSight PMC GPR 1P"},
              {"name": "DBG_PMC_CTI", "addr": "0xf08d0000", "size": "64K", "altname": "CoreSight_PMC_CTI", "desc": "CoreSight PMC Map Trigger and Channel interfaces"},
              {"name": "DBG_LPD", "addr": "0xf0900000", "size": "1M"},
              {"name": "DBG_LPD_ROM", "addr": "0xf0900000", "size": "64K", "altname": "CoreSight_LPD_ROM", "desc": "CoreSight LPD ROM"},
              {"name": "DBG_LPD_GPR", "addr": "0xf0910000", "size": "64K", "altname": "CoreSight_LPD_GPR", "desc": "CoreSight LPD GPR 3P"},
              {"name": "DBG_LPD_FUN", "addr": "0xf0920000", "size": "64K", "altname": "CoreSight_LPD_FUN", "desc": "CoreSight LPD Merge Five Trace Streams to ATB"},
              {"name": "DBG_TSG_RW", "addr": "0xf0990000", "size": "64K", "altname": "CoreSight_LPD_TSG", "desc": "CoreSight Master Time Stamp with Read/Write"},
              {"name": "DBG_LPD_CTI", "addr": "0xf09d0000", "size": "64K", "altname": "CoreSight_LPD_CTI", "desc": "CoreSight LPD Map Trigger and Channel interfaces"},
              {"name": "DBG_R5", "addr": "0xf0a00000", "size": "1M"},
              {"name": "DBG_RPU0_DBG", "addr": "0xf0a00000", "size": "64K", "altname": "CoreSight_R50_DBG", "desc": "CoreSight RPU0 Built-in Debug Logic"},
              {"name": "DBG_RPU0_CTI", "addr": "0xf0a10000", "size": "64K", "altname": "CoreSight_R50_CTI", "desc": "CoreSight RPU0 Map Trigger and Channel interfaces"},
              {"name": "DBG_RPU0_ETM", "addr": "0xf0a30000", "size": "64K", "altname": "CoreSight_R50_ETM", "desc": "CoreSight RPU 0 Generate Trace"},
              {"name": "DBG_RPU1_DBG", "addr": "0xf0a40000", "size": "64K", "altname": "CoreSight_R51_DBG", "desc": "CoreSight RPU1 Built-in Debug Logic"},
              {"name": "DBG_RPU1_CTI", "addr": "0xf0a50000", "size": "64K", "altname": "CoreSight_R51_CTI", "desc": "CoreSight RPU1 Map Trigger and Channel interfaces"},
              {"name": "DBG_RPU1_ETM", "addr": "0xf0a70000", "size": "64K", "altname": "CoreSight_R51_ETM", "desc": "CoreSight RPU1 Generate Trace"},
              {"name": "DBG_FPD", "addr": "0xf0b00000", "size": "1M"},
              {"name": "DBG_FPD_ROM", "addr": "0xf0b00000", "size": "64K", "altname": "CoreSight_FPD_ROM", "desc": "CoreSight FPD ROM"},
              {"name": "DBG_FPD_GPR", "addr": "0xf0b10000", "size": "64K", "altname": "CoreSight_FPD_GPR", "desc": "CoreSight FPD GPR 2P"},
              {"name": "DBG_FPD_FUN", "addr": "0xf0b20000", "size": "64K", "altname": "CoreSight_FPD_FUN", "desc": "CoreSight LPD Merge Six Trace Streams to ATB"},
              {"name": "DBG_FPD_ETF", "addr": "0xf0b30000", "size": "64K", "altname": "CoreSight_FPD_ETF", "desc": "CoreSight FPD Embedded 32K Trace FIFO"},
              {"name": "DBG_FPD_REPL", "addr": "0xf0b40000", "size": "64K", "altname": "CoreSight_FPD_REPL", "desc": "CoreSight Replicates ATB Data Stream"},
              {"name": "DBG_FPD_ETR", "addr": "0xf0b50000", "size": "64K", "altname": "CoreSight_FPD_ETR", "desc": "CoreSight FPD Enable Local Trace Buffer"},
              {"name": "DBG_TPIU", "addr": "0xf0b60000", "size": "64K", "altname": "CoreSight_FPD_TPIU", "desc": "CoreSight Test port interface unit"},
              {"name": "DBG_STM", "addr": "0xf0b70000", "size": "64K", "altname": "CoreSight_FPD_STM", "desc": "CoreSight System Trace Module"},
              {"name": "DBG_FPD_CTI1B", "addr": "0xf0bb0000", "size": "64K", "altname": "CoreSight_FPD_CTI1B", "desc": "CoreSight FPD 1B Map Trigger and Channel interfaces"},
              {"name": "DBG_FPD_CTI1C", "addr": "0xf0bc0000", "size": "64K", "altname": "CoreSight_FPD_CTI1C", "desc": "CoreSight FPD 1C Map Trigger and Channel interfaces"},
              {"name": "DBG_FPD_CTI1D", "addr": "0xf0bd0000", "size": "64K", "altname": "CoreSight_FPD_CTI1D", "desc": "CoreSight FPD 1D Map Trigger and Channel interfaces"},
              {"name": "DBG_APU", "addr": "0xf0c00000", "size": "1M"},
              {"name": "DBG_APU_FUN", "addr": "0xf0c20000", "size": "64K", "altname": "CoreSight_APU_FUN", "desc": "CoreSight APU Merge Two Trace Streams to ATB"},
              {"name": "DBG_APU_ETF", "addr": "0xf0c30000", "size": "64K", "altname": "CoreSight_APU_ETF", "desc": "CoreSight APU Embedded 4K Trace FIFO"},
              {"name": "DBG_APU_ELA", "addr": "0xf0c60000", "size": "64K", "altname": "CoreSight_APU_ELA", "desc": "CoreSight APU Embedded 128 Logic Analyzer"},
              {"name": "DBG_APU_CTI", "addr": "0xf0ca0000", "size": "64K", "altname": "CoreSight_APU_CTI", "desc": "CoreSight APU MPCore Map Trigger and Channel"},
              {"name": "DBG_A72", "addr": "0xf0d00000", "size": "1M"},
              {"name": "DBG_APU0_DBG", "addr": "0xf0d00000", "size": "64K", "altname": "CoreSight_A720_DBG", "desc": "CoreSight APU0 Built-in Debug Logic"},
              {"name": "DBG_APU0_CTI", "addr": "0xf0d10000", "size": "64K", "altname": "CoreSight_A720_CTI", "desc": "CoreSight APU0 Map Trigger and Channel interfaces"},
              {"name": "DBG_APU0_PMU", "addr": "0xf0d20000", "size": "64K", "altname": "CoreSight_A720_PMU", "desc": "CoreSight APU0 Processor Performance Profile"},
              {"name": "DBG_APU0_ETM", "addr": "0xf0d30000", "size": "64K", "altname": "CoreSight_A720_ETM", "desc": "CoreSight APU0 Generate Trace"},
              {"name": "DBG_APU1_DBG", "addr": "0xf0d40000", "size": "64K", "altname": "CoreSight_A721_DBG", "desc": "CoreSight APU1 Built-in Debug Logic"},
              {"name": "DBG_APU1_CTI", "addr": "0xf0d50000", "size": "64K", "altname": "CoreSight_A721_CTI", "desc": "CoreSight APU1 Map Trigger and Channel interfaces"},
              {"name": "DBG_APU1_PMU", "addr": "0xf0d60000", "size": "64K", "altname": "CoreSight_A721_PMU", "desc": "CoreSight APU1 Processor Performance Profile"},
              {"name": "DBG_APU1_ETM", "addr": "0xf0d70000", "size": "64K", "altname": "CoreSight_A721_ETM", "desc": "CoreSight APU1 Generate Trace"},
              {"name": "DBG_CPM", "addr": "0xf0f00000", "size": "1M"},
              {"name": "DBG_CPM_ROM", "addr": "0xf0f00000", "size": "64K", "altname": "CoreSight_CPM_ROM", "desc": "CoreSight CPM ROM"},
              {"name": "DBG_CPM_FUN", "addr": "0xf0f20000", "size": "64K", "altname": "CoreSight_CPM_FUN", "desc": "CoreSight CPM Merge Two Trace Streams to ATB"},
              {"name": "DBG_CPM_ELA2A", "addr": "0xf0f40000", "size": "64K", "altname": "CoreSight_CPM_ELA2A", "desc": "CoreSight CPM 2A Embedded 256 Logic Analyzer"},
              {"name": "DBG_CPM_ELA2B", "addr": "0xf0f50000", "size": "64K", "altname": "CoreSight_CPM_ELA2B", "desc": "CoreSight CPM 2B Embedded 256 Logic Analyzer"},
              {"name": "DBG_CPM_ELA2C", "addr": "0xf0f60000", "size": "64K", "altname": "CoreSight_CPM_ELA2C", "desc": "CoreSight CPM 2C Embedded 256 Logic Analyzer"},
              {"name": "DBG_CPM_ELA2D", "addr": "0xf0f70000", "size": "64K", "altname": "CoreSight_CPM_ELA2D", "desc": "CoreSight CPM 2D Embedded 256 Logic Analyzer"},
              {"name": "DBG_CPM_CTI2A", "addr": "0xf0fa0000", "size": "64K", "altname": "CoreSight_CPM_CTI2A", "desc": "CoreSight CPM 2A Map Trigger and Channel interfaces"},
              {"name": "DBG_CPM_CTI2D", "addr": "0xf0fd0000", "size": "64K", "altname": "CoreSight_CPM_CTI2D", "desc": "CoreSight CPM 2D Map Trigger and Channel interfaces"},
              {"name": "PMC_XPPU_64KB_apertures", "addr": "0xf1000000", "size": "16M"},
              {"name": "PMC_I2C", "addr": "0xf1000000", "size": "64K", "nodeid": "0x1822402d", "param": "PMC_I2CPMC_PERIPHERAL_ENABLE", "desc": "PMC I2C controller"},
              {"name": "OSPI", "addr": "0xf1010000", "size": "64K", "nodeid": "0x1822402a", "smid": "OSPI", "param": "PMC_OSPI_ENABLE", "type": "manager", "desc": "Octal-SPI control. May require PMC_OSPI_mem"},
              {"name": "PMC_GPIO", "addr": "0xf1020000", "size": "64K", "nodeid": "0x1822402c", "param": "PMC_GPIO_ENABLE", "desc": "General Purpose I/O in PMC"},
              {"name": "QSPI", "addr": "0xf1030000", "size": "64K", "nodeid": "0x1822402b", "smid": "QSPI", "param": "PMC_QSPI_ENABLE", "type": "manager", "desc": "Quad-SPI control"},
              {"name": "SD_eMMC0", "addr": "0xf1040000", "size": "64K", "altname": "SD0", "nodeid": "0x1822402e", "smid": "SD_eMMC0", "param": "PMC_SD0_PERIPHERAL_ENABLE", "type": "manager", "desc": "SD/eMMC controller 0"},
              {"name": "SD_eMMC1", "addr": "0xf1050000", "size": "64K", "altname": "SD1", "nodeid": "0x1822402f", "smid": "SD_eMMC1", "param": "PMC_SD1_PERIPHERAL_ENABLE", "type": "manager", "desc": "SD/eMMC controller 1"},
              {"name": "PMC_IOP_SLCR", "addr": "0xf1060000", "size": "64K", "altname": "PMC_IOU_SLCR", "desc": "PMC IOP SLCR registers; non-secure"},
              {"name": "PMC_IOP_SLCR_SECURE", "addr": "0xf1070000", "size": "64K", "altname": "PMC_IOU_SECURE_SLCR", "desc": "PMC IOP SLCR registers; secure"},
              {"name": "PMC_IOP_INT_GPV", "addr": "0xf1080000", "size": "64K", "altname": "PMC_IOU_GPV", "desc": "PMC IOP Interconnect Global Programmers View (GPV)"},
              {"name": "PMC_RAM_CSR", "addr": "0xf1100000", "size": "64K", "altname": "PMC_RAM_CFG", "desc": "PMC On-chip Memory configuration"},
              {"name": "PMC_GLOBAL", "addr": "0xf1110000", "size": "320K", "desc": "PMC Global registers"},
              {"name": "PMC_ANLG", "addr": "0xf1160000", "size": "256K", "altname": "PMC_ANALOG", "desc": "PMC analog control"},
              {"name": "PMC_JTAG_CSR", "addr": "0xf11a0000", "size": "128K", "altname": "PMC_TAP", "desc": "PMC JTAG TAP control"},
              {"name": "PMC_DMA0_CSR", "addr": "0xf11c0000", "size": "64K", "altname": "PMC_DMA0", "smid": "PMC_DMA0", "type": "manager", "desc": "PMC DMA 0 Control"},
              {"name": "PMC_DMA1_CSR", "addr": "0xf11d0000", "size": "64K", "altname": "PMC_DMA1", "smid": "PMC_DMA1", "type": "manager", "desc": "PMC DMA 1 Control"},
              {"name": "PMC_AES", "addr": "0xf11e0000", "size": "64K", "altname": "AES", "desc": "AES Module (controlled under NDA)"},
              {"name": "PMC_BBRAM_CTRL", "addr": "0xf11f0000", "size": "64K", "altname": "BBRAM_CTRL", "desc": "Batter-backed RAM; BBRAM  (controlled under NDA)"},
              {"name": "PMC_ECDSA_RSA", "addr": "0xf1200000", "size": "64K", "altname": "ECDSA_RSA", "desc": "ECDSA and RSA control (controlled under NDA)"},
              {"name": "PMC_SHA3", "addr": "0xf1210000", "size": "64K", "altname": "SHA3", "desc": "SHA3 Module (controlled under NDA)"},
              {"name": "PMC_SBI_CSR", "addr": "0xf1220000", "size": "64K", "altname": "SLAVE_BOOT", "desc": "Boot Interface"},
              {"name": "PMC_TRNG", "addr": "0xf1230000", "size": "64K", "altname": "TRNG", "desc": "True Random Number Generator (controlled under NDA)"},
              {"name": "PMC_EFUSE_CTRL", "addr": "0xf1240000", "size": "64K", "altname": "EFUSE_CTRL", "desc": "EFuse Control Unit (partially controlled under NDA)"},
              {"name": "PMC_EFUSE_CACHE", "addr": "0xf1250000", "size": "64K", "altname": "EFUSE_CACHE", "nodeid": "0x18330054", "desc": "EFuse Cache (mostly controlled under NDA)"},
              {"name": "CRP", "addr": "0xf1260000", "size": "64K", "desc": "PMC Clock and Reset control"},
              {"name": "PMC_SYSMON_CSR", "addr": "0xf1270000", "size": "64K", "altname": "PMC_SYSMON", "nodeid": "0x18224055", "smid": "PMC_SYSMON", "type": "manager", "desc": "PMC System Monitor control"},
              {"name": "PMC_RTC", "addr": "0xf12a0000", "size": "64K", "altname": "RTC", "nodeid": "0x18224034", "desc": "RTC Registers"},
              {"name": "CFU_CSR", "addr": "0xf12b0000", "size": "64K", "altname": "CFU_APB", "desc": "CFU Registers (aka CFU_APB)"},
              {"name": "CFU_mem", "addr": "0xf12c0000", "size": "64K", "mem": true},
              {"name": "CFU_SFR_mem", "addr": "0xf12c1000", "size": "4K", "mem": true, "desc": "Single Frame Address"},
              {"name": "CFU_FDRO_mem", "addr": "0xf12c2000", "size": "4K", "mem": true, "desc": "Frame Data Register Output (read config data)"},
              {"name": "CFRAME", "addr": "0xf12d0000", "size": "128K"},
              {"name": "PMC_XMPU", "addr": "0xf12f0000", "size": "64K", "desc": "PMC Memory Protection Unit"},
              {"name": "PMC_XPPU_NPI", "addr": "0xf1300000", "size": "64K", "desc": "NPI Host Memory Protection Unit"},
              {"name": "PMC_XPPU", "addr": "0xf1310000", "size": "64K", "desc": "PMC Peripheral Protection Unit"},
              {"name": "PMC_INT_GPV", "addr": "0xf1320000", "size": "64K", "altname": "PMC_MAIN_GPV", "desc": "PMC Interconnect Global Programmers View (GPV)"},
              {"name": "PMC_INT_CSR", "addr": "0xf1330000", "size": "2560K", "altname": "INTPMC_CONFIG", "desc": "PMC reset and isolation interconnect ports"},
              {"name": "CFU_STREAM_mem", "addr": "0xf1f80000", "size": "256K", "mem": true, "desc": "CFU Stream memory"},
              {"name": "PMC_XMPU_mem", "addr": "0xf2000000", "size": "2M", "mem": true, "nodeid": "0x18900007", "xmpu": "PMC_XMPU"},
              {"name": "PMC_RAM_mem", "addr": "0xf2000000", "size": "128K", "mem": true, "desc": "PMC RAM (128 KB) - Note: The usage of this memory is defined by the PLM."},
              {"name": "PLM_RTCA", "addr": "0xf2014000", "size": "4K", "desc": "Real-time Configuration Area - Note: Fixed location in PMC RAM"},
              {"name": "PMC_SBI_STREAM_mem", "addr": "0xf2100000", "size": "64K", "mem": true, "desc": "SBI Stream memory"},
              {"name": "NPI_HOST_mem", "addr": "0xf6000000", "size": "32M", "mem": true, "desc": "NPI Host controller memory space"},
              {"name": "PMC_XPPU_NPI_64KB_apertures", "addr": "0xf6000000", "size": "16M"},
              {"name": "DDRMC_NOC_0", "addr": "0xf6070000", "size": "128K"},
              {"name": "DDRMC_UB_0", "addr": "0xf6110000", "size": "256K"},
              {"name": "DDRMC_MAIN_0", "addr": "0xf6150000", "size": "64K"},
              {"name": "NOC_NMU_10", "addr": "0xf6230000", "size": "8K", "site": "NOC_NMU512_X0Y0"},
              {"name": "NOC_NMU_11", "addr": "0xf6260000", "size": "8K", "site": "NOC_NMU512_X0Y1"},
              {"name": "NOC_NMU_12", "addr": "0xf6290000", "size": "8K", "site": "NOC_NMU512_X0Y2"},
              {"name": "NOC_NMU_13", "addr": "0xf62b0000", "size": "8K", "site": "NOC_NMU512_X0Y3"},
              {"name": "NOC_NMU_14", "addr": "0xf62e0000", "size": "8K", "site": "NOC_NMU512_X0Y4"},
              {"name": "AIE_CSR", "addr": "0xf6420000", "size": "64K", "desc": "AIE interrupt registers"},
              {"name": "PMC_XPPU_NPI_1MB_apertures", "addr": "0xf7000000", "size": "16M"},
              {"name": "FPD", "addr": "0xf8000000", "size": "96M", "xmpu": "FPD_XMPU"},
              {"name": "CoreSight_STM_mem", "addr": "0xf8000000", "size": "16M", "mem": true, "desc": "Debug System Trace Macrocell"},
              {"name": "APU_GIC", "addr": "0xf9000000", "size": "1M"},
              {"name": "APU_GIC_DIST_MAIN", "addr": "0xf9000000", "size": "64K", "smid": "APU_GIC", "type": "manager", "desc": "APU GIC-500 Main Distributor"},
              {"name": "APU_GIC_DIST_MBSPI", "addr": "0xf9010000", "size": "64K", "desc": "APU GIC SPI Interrupt Distributor"},
              {"name": "APU_GIC_ITS_CTL", "addr": "0xf9020000", "size": "64K", "desc": "APU GIC ITS control"},
              {"name": "APU_GIC_ITS_TRANS", "addr": "0xf9030000", "size": "64K", "desc": "APU GIC ITS service (translator) accessed only by CPM"},
              {"name": "APU_GIC_CPUIF", "addr": "0xf9040000", "size": "64K", "altname": "APU_GIC_A72_CPUIF", "desc": "APU GIC CPU Interface"},
              {"name": "APU_GIC_VIFCTL", "addr": "0xf9050000", "size": "64K", "altname": "APU_GIC_A72_VIFCTL", "desc": "APU GIC CPU Virtual Interface Control"},
              {"name": "APU_GIC_VCPUIF", "addr": "0xf9060000", "size": "64K", "altname": "APU_GIC_A72_VCPUIF", "desc": "APU GIC CPU Virtual Interface"},
              {"name": "APU_GIC_REDIST_CTLLPI_0", "addr": "0xf9080000", "size": "64K", "desc": "APU 0 GIC Redistributor control and Physical LPI"},
              {"name": "APU_GIC_REDIST_SGISPI_0", "addr": "0xf9090000", "size": "64K", "desc": "APU 0 GIC Redistributor for SGI and PPI"},
              {"name": "APU_GIC_REDIST_CTLLPI_1", "addr": "0xf90a0000", "size": "64K", "desc": "APU 1 GIC Redistributor control and Physical LPI"},
              {"name": "APU_GIC_REDIST_SGISPI_1", "addr": "0xf90b0000", "size": "64K", "desc": "APU 1 GIC Redistributor for SGI and PPI"},
              {"name": "CPM", "addr": "0xfc000000", "size": "16M", "desc": "Protected by the LPD_XPPU aperture 400. Not in FPD even though the addresses are within the FPD address range"},
              {"name": "FPD_devs", "addr": "0xfd000000", "size": "16M"},
              {"name": "FPD_CCI_CORE", "addr": "0xfd000000", "size": "1M", "altname": "FPD_MAINCCI", "desc": "Cache Coherent Interconnect (CCI-500) in FPD"},
              {"name": "CRF", "addr": "0xfd1a0000", "size": "1280K", "desc": "FPD Clock and Reset controller"},
              {"name": "PL_AXI_FPD_CSR", "addr": "0xfd360000", "size": "64K", "altname": "FPD_AFIFM0", "desc": "PL to PS AXI Interface control (aka S_AXI_HP; AFIFM0)"},
              {"name": "FPD_INT_CSR", "addr": "0xfd370000", "size": "64K", "altname": "INTFPD_CONFIG", "desc": "FPD Interconnect control; wrapper"},
              {"name": "PL_ACELITE_FPD_CSR", "addr": "0xfd380000", "size": "64K", "altname": "FPD_AFIFM2", "desc": "PL to PS Coherent AXI control (aka S_AXI_HPC; AFIFM2)"},
              {"name": "FPD_XMPU", "addr": "0xfd390000", "size": "64K", "altname": "FPD_SLAVE_XMPU", "desc": "FPD Memory Protection Unit"},
              {"name": "FPD_SWDT", "addr": "0xfd4d0000", "size": "64K", "altname": "FPD_WWDT", "nodeid": "0x18224029", "param": "PS_WWDT1_PERIPHERAL_ENABLE", "desc": "FPD System Watchdog Timer (aka SWDT1; WWDT1)"},
              {"name": "APU_DUAL_CSR", "addr": "0xfd5c0000", "size": "64K", "altname": "FPD_APU", "desc": "APU control and status"},
              {"name": "FPD_CCI_CSR", "addr": "0xfd5e0000", "size": "64K", "altname": "FPD_GPCCI", "desc": "Cache Coherent Interconnect  (aka CCI_REG)"},
              {"name": "FPD_SMMU_CSR", "addr": "0xfd5f0000", "size": "64K", "altname": "FPD_SMMU", "smid": "FPD_SMMU", "type": "manager", "desc": "System Memory Management Unit"},
              {"name": "FPD_SLCR", "addr": "0xfd610000", "size": "64K", "desc": "FPD System-level Control"},
              {"name": "FPD_SLCR_SECURE", "addr": "0xfd690000", "size": "64K", "desc": "FPD System-level Control (secure)"},
              {"name": "FPD_INT_GPV", "addr": "0xfd700000", "size": "1M", "altname": "FPD_GPV", "desc": "FPD Interconnect Global Programmers View (GPV)"},
              {"name": "FPD_SMMU", "addr": "0xfd800000", "size": "8M", "altname": "FPD_SMMUTCU", "smid": "FPD_SMMU", "type": "manager", "desc": "SMMU core (non-secure space)"},
              {"name": "LPD", "addr": "0xfe000000", "size": "32M"},
              {"name": "LPD_XPPU_1MB_apertures", "addr": "0xfe000000", "size": "16M"},
              {"name": "LPD_IOP_INT_GPV", "addr": "0xfe000000", "size": "1M", "altname": "LPD_IOU_GPV", "desc": "LPD IOP Interconnect Global Programmers View (GPV)"},
              {"name": "USB2_XHCI", "addr": "0xfe200000", "size": "1M", "altname": "USB_XHCI", "param": "PS_USB3_PERIPHERAL_ENABLE", "desc": "USB 2.0 XHCI registers"},
              {"name": "LPD_INT_GPV", "addr": "0xfe400000", "size": "128K", "altname": "LPD_GPV", "desc": "LPD Interconnect Global Programmers View (GPV)"},
              {"name": "DPC_DMA_CSR", "addr": "0xfe5f0000", "size": "64K", "altname": "HSDP_DMA", "smid": "DPC_DMA", "type": "manager", "desc": "Debug Port Controller DMA unit"},
              {"name": "LPD_INT_CSR", "addr": "0xfe600000", "size": "2M", "altname": "INTLPD_CONFIG", "desc": "LPD Interconnect Timeout; Reset; and Isolation"},
              {"name": "XRAM_mem", "addr": "0xfe800000", "size": "4M", "mem": true, "desc": "On-chip Accelerator RAM; 4 MB"},
              {"name": "XRAM0_mem", "addr": "0xfe800000", "size": "1M", "mem": true, "xmpu": "XRAM_XMPU0"},
              {"name": "XRAM0_0_mem", "addr": "0xfe800000", "size": "256K", "mem": true, "nodeid": "0x18334056"},
              {"name": "XRAM0_1_mem", "addr": "0xfe840000", "size": "256K", "mem": true, "nodeid": "0x18334057"},
              {"name": "XRAM0_2_mem", "addr": "0xfe880000", "size": "256K", "mem": true, "nodeid": "0x18334058"},
              {"name": "XRAM0_3_mem", "addr": "0xfe8c0000", "size": "256K", "mem": true, "nodeid": "0x18334059"},
              {"name": "XRAM1_mem", "addr": "0xfe900000", "size": "1M", "mem": true, "xmpu": "XRAM_XMPU1"},
              {"name": "XRAM1_0_mem", "addr": "0xfe900000", "size": "256K", "mem": true, "nodeid": "0x1833405a"},
              {"name": "XRAM1_1_mem", "addr": "0xfe940000", "size": "256K", "mem": true, "nodeid": "0x1833405b"},
              {"name": "XRAM1_2_mem", "addr": "0xfe980000", "size": "256K", "mem": true, "nodeid": "0x1833405c"},
              {"name": "XRAM1_3_mem", "addr": "0xfe9c0000", "size": "256K", "mem": true, "nodeid": "0x1833405d"},
              {"name": "XRAM2_mem", "addr": "0xfea00000", "size": "1M", "mem": true, "xmpu": "XRAM_XMPU2"},
              {"name": "XRAM2_0_mem", "addr": "0xfea00000", "size": "256K", "mem": true, "nodeid": "0x1833405e"},
              {"name": "XRAM2_1_mem", "addr": "0xfea40000", "size": "256K", "mem": true, "nodeid": "0x1833405f"},
              {"name": "XRAM2_2_mem", "addr": "0xfea80000", "size": "256K", "mem": true, "nodeid": "0x18334060"},
              {"name": "XRAM2_3_mem", "addr": "0xfeac0000", "size": "256K", "mem": true, "nodeid": "0x18334061"},
              {"name": "XRAM3_mem", "addr": "0xfeb00000", "size": "1M", "mem": true, "xmpu": "XRAM_XMPU3"},
              {"name": "XRAM3_0_mem", "addr": "0xfeb00000", "size": "256K", "mem": true, "nodeid": "0x18334062"},
              {"name": "XRAM3_1_mem", "addr": "0xfeb40000", "size": "256K", "mem": true, "nodeid": "0x18334063"},
              {"name": "XRAM3_2_mem", "addr": "0xfeb80000", "size": "256K", "mem": true, "nodeid": "0x18334064"},
              {"name": "XRAM3_3_mem", "addr": "0xfebc0000", "size": "256K", "mem": true, "nodeid": "0x18334065"},
              {"name": "LPD_XPPU_64KB_apertures", "addr": "0xff000000", "size": "15M"},
              {"name": "UART0", "addr": "0xff000000", "size": "64K", "nodeid": "0x18224021", "param": "PS_UART0_PERIPHERAL_ENABLE", "desc": "UART 0 controller"},
              {"name": "UART1", "addr": "0xff010000", "size": "64K", "nodeid": "0x18224022", "param": "PS_UART1_PERIPHERAL_ENABLE", "desc": "UART 1 controller"},
              {"name": "LPD_I2C0", "addr": "0xff020000", "size": "64K", "altname": "PS_I2C0", "nodeid": "0x1822401d", "param": "PS_I2C0_PERIPHERAL_ENABLE", "desc": "Inter-integrated Circuit  controller 0"},
              {"name": "LPD_I2C1", "addr": "0xff030000", "size": "64K", "altname": "PS_I2C1", "nodeid": "0x1822401e", "param": "PS_I2C1_PERIPHERAL_ENABLE", "desc": "Inter-integrated Circuit  controller 1"},
              {"name": "SPI0", "addr": "0xff040000", "size": "64K", "nodeid": "0x1822401b", "param": "PS_SPI0_PERIPHERAL_ENABLE", "desc": "Serial Peripheral Interface 0"},
              {"name": "SPI1", "addr": "0xff050000", "size": "64K", "nodeid": "0x1822401c", "param": "PS_SPI1_PERIPHERAL_ENABLE", "desc": "Serial Peripheral Interface 1"},
              {"name": "CANFD0", "addr": "0xff060000", "size": "64K", "nodeid": "0x1822401f", "param": "PS_CAN0_PERIPHERAL_ENABLE", "desc": "Controller Area Network 0"},
              {"name": "CANFD1", "addr": "0xff070000", "size": "64K", "nodeid": "0x18224020", "param": "PS_CAN1_PERIPHERAL_ENABLE", "desc": "Controller Area Network 1"},
              {"name": "LPD_IOP_SLCR", "addr": "0xff080000", "size": "128K", "altname": "LPD_IOU_SLCR", "desc": "LPD IOP System-level Control"},
              {"name": "LPD_IOP_SLCR_SECURE", "addr": "0xff0a0000", "size": "64K", "altname": "LPD_IOU_SECURE_SLCR", "desc": "LPD IOP System-level Control; secure"},
              {"name": "LPD_GPIO", "addr": "0xff0b0000", "size": "64K", "altname": "PS_GPIO", "nodeid": "0x18224023", "param": "PS_GPIO_ENABLE", "desc": "LPD General Purpose I/O"},
              {"name": "GEM0", "addr": "0xff0c0000", "size": "64K", "nodeid": "0x18224019", "smid": "GEM0", "param": "PS_ENET0_PERIPHERAL_ENABLE", "type": "manager", "desc": "Gigabit Ethernet MAC (GEM) controller 0"},
              {"name": "GEM1", "addr": "0xff0d0000", "size": "64K", "nodeid": "0x1822401a", "smid": "GEM1", "param": "PS_ENET1_PERIPHERAL_ENABLE", "type": "manager", "desc": "Gigabit Ethernet MAC  (GEM) controller 1"},
              {"name": "TTC", "addr": "0xff0e0000", "size": "256K"},
              {"name": "TTC0", "addr": "0xff0e0000", "size": "64K", "nodeid": "0x18224024", "param": "PS_TTC0_PERIPHERAL_ENABLE", "desc": "Triple Timer Counter 0"},
              {"name": "TTC1", "addr": "0xff0f0000", "size": "64K", "nodeid": "0x18224025", "param": "PS_TTC1_PERIPHERAL_ENABLE", "desc": "Triple Timer Counter 1"},
              {"name": "TTC2", "addr": "0xff100000", "size": "64K", "nodeid": "0x18224026", "param": "PS_TTC2_PERIPHERAL_ENABLE", "desc": "Triple Timer Counter 2"},
              {"name": "TTC3", "addr": "0xff110000", "size": "64K", "nodeid": "0x18224027", "param": "PS_TTC3_PERIPHERAL_ENABLE", "desc": "Triple Timer Counter 3"},
              {"name": "LPD_SWDT", "addr": "0xff120000", "size": "64K", "altname": "WWDT", "nodeid": "0x18224028", "param": "PS_WWDT0_PERIPHERAL_ENABLE", "desc": "LPD System Watchdog Timer  (aka SWDT0; WWDT0)"},
              {"name": "SCNTR", "addr": "0xff130000", "size": "64K", "altname": "IOU_SCNTR", "desc": "System Counter; non-secure"},
              {"name": "SCNTR_SECURE", "addr": "0xff140000", "size": "64K", "altname": "IOU_SCNTRS", "desc": "System Counter; secure (scntrs)"},
              {"name": "IPI", "addr": "0xff300000", "size": "1M", "desc": "Inter-processor Interrupts"},
              {"name": "IPI_CSR", "addr": "0xff300000", "size": "64K"},
              {"name": "IPI_channels", "addr": "0xff310000", "size": "640K", "desc": "Inter-Processor Interrupt channel registers"},
              {"name": "IPI_PSM", "addr": "0xff310000", "size": "64K", "type": "ipi", "desc": "IPI PSM Channel", "constants": {"master": "PSM", "mid_ro": true, "override_en": true}},
              {"name": "IPI_PMC", "addr": "0xff320000", "size": "64K", "type": "ipi", "desc": "IPI PMC Channel", "constants": {"master": "PPU", "mid_ro": true, "override_en": true}},
              {"name": "IPI0", "addr": "0xff330000", "size": "64K", "nodeid": "0x1822403d", "type": "ipi", "desc": "IPI Channel 0"},
              {"name": "IPI1", "addr": "0xff340000", "size": "64K", "nodeid": "0x1822403e", "type": "ipi", "desc": "IPI Channel 1"},
              {"name": "IPI2", "addr": "0xff350000", "size": "64K", "nodeid": "0x1822403f", "type": "ipi", "desc": "IPI Channel 2"},
              {"name": "IPI3", "addr": "0xff360000", "size": "64K", "nodeid": "0x18224040", "type": "ipi", "desc": "IPI Channel 3"},
              {"name": "IPI4", "addr": "0xff370000", "size": "64K", "nodeid": "0x18224041", "type": "ipi", "desc": "IPI Channel 4"},
              {"name": "IPI5", "addr": "0xff380000", "size": "64K", "nodeid": "0x18224042", "type": "ipi", "desc": "IPI Channel 5"},
              {"name": "IPI_PMC_NOBUF", "addr": "0xff390000", "size": "4K", "type": "ipi", "desc": "IPI PMC Channel; no buffer", "constants": {"master": "PPU", "mid_ro": true, "override_en": false}},
              {"name": "IPI6", "addr": "0xff3a0000", "size": "4K", "nodeid": "0x18224043", "type": "ipi", "desc": "IPI Channel 6; no buffer"},
              {"name": "IPI_buffers", "addr": "0xff3f0000", "size": "64K", "desc": "Inter-Processor Interrupt request/receive buffers"},
              {"name": "LPD_SLCR", "addr": "0xff410000", "size": "1M", "desc": "LPD System-level control"},
              {"name": "LPD_SLCR_SECURE", "addr": "0xff510000", "size": "256K", "desc": "LPD System-level control; secure"},
              {"name": "CRL", "addr": "0xff5e0000", "size": "3M", "desc": "LPD Clock and Reset controller"},
              {"name": "CRL_0", "addr": "0xff5e0000", "size": "64K", "desc": "First aperture in CRL"},
              {"name": "XRAM_CTRL0", "addr": "0xff8e0000", "size": "64K", "desc": "XRAM Bank 0 control"},
              {"name": "XRAM_CTRL1", "addr": "0xff8f0000", "size": "64K", "desc": "XRAM Bank 1 control"},
              {"name": "XRAM_CTRL2", "addr": "0xff900000", "size": "64K", "desc": "XRAM Bank 2 control"},
              {"name": "XRAM_CTRL3", "addr": "0xff910000", "size": "64K", "desc": "XRAM Bank 3 control"},
              {"name": "XRAM_XMPU", "addr": "0xff930000", "size": "64K"},
              {"name": "XRAM_XMPU0", "addr": "0xff930000", "size": "16K", "desc": "XRAM Memory Protection Unit 0"},
              {"name": "XRAM_XMPU1", "addr": "0xff934000", "size": "16K", "desc": "XRAM Memory Protection Unit 1"},
              {"name": "XRAM_XMPU2", "addr": "0xff938000", "size": "16K", "desc": "XRAM Memory Protection Unit 2"},
              {"name": "XRAM_XMPU3", "addr": "0xff93c000", "size": "16K", "desc": "XRAM Memory Protection Unit 3"},
              {"name": "XRAM_INT_GPV", "addr": "0xff940000", "size": "64K", "altname": "XRAM_GPV", "desc": "XRAM Interconnect Global Programmers View (GPV)"},
              {"name": "XRAM_SLCR", "addr": "0xff950000", "size": "64K", "desc": "XRAM System-level control"},
              {"name": "OCM_CSR", "addr": "0xff960000", "size": "64K", "altname": "OCM", "desc": "On-chip Memory control"},
              {"name": "OCM_XMPU", "addr": "0xff980000", "size": "64K", "desc": "OCM Memory Protection control"},
              {"name": "LPD_XPPU", "addr": "0xff990000", "size": "64K", "desc": "LPD Peripheral Protection control"},
              {"name": "RPU_DUAL_CSR", "addr": "0xff9a0000", "size": "64K", "altname": "RPU", "smid": "RPU", "type": "manager", "desc": "RPU control and status"},
              {"name": "PL_AXI_LPD_CSR", "addr": "0xff9b0000", "size": "64K", "altname": "LPD_AFIFM4", "desc": "PL to PS 128-bit AXI Channel (aka AFIFM4)"},
              {"name": "DPC_AURORA", "addr": "0xff9c0000", "size": "64K", "altname": "AURORA", "desc": "Aurora Debug Interface"},
              {"name": "USB2_CSR", "addr": "0xff9d0000", "size": "64K", "altname": "USB2_REGS", "nodeid": "0x18224018", "smid": "USB2", "param": "PS_USB3_PERIPHERAL_ENABLE", "type": "manager", "desc": "USB 2.0 control in LPD"},
              {"name": "LPD_DMA_CH", "addr": "0xffa80000", "size": "512K"},
              {"name": "LPD_DMA_CH0", "addr": "0xffa80000", "size": "64K", "altname": "ADMA_CH0", "nodeid": "0x18224035", "smid": "LPD_DMA_CH0", "type": "manager", "desc": "General purpose DMA channel 0 (ADMA)"},
              {"name": "LPD_DMA_CH1", "addr": "0xffa90000", "size": "64K", "altname": "ADMA_CH1", "nodeid": "0x18224036", "smid": "LPD_DMA_CH1", "type": "manager", "desc": "General purpose DMA channel 1"},
              {"name": "LPD_DMA_CH2", "addr": "0xffaa0000", "size": "64K", "altname": "ADMA_CH2", "nodeid": "0x18224037", "smid": "LPD_DMA_CH2", "type": "manager", "desc": "General purpose DMA channel 2"},
              {"name": "LPD_DMA_CH3", "addr": "0xffab0000", "size": "64K", "altname": "ADMA_CH3", "nodeid": "0x18224038", "smid": "LPD_DMA_CH3", "type": "manager", "desc": "General purpose DMA channel 3"},
              {"name": "LPD_DMA_CH4", "addr": "0xffac0000", "size": "64K", "altname": "ADMA_CH4", "nodeid": "0x18224039", "smid": "LPD_DMA_CH4", "type": "manager", "desc": "General purpose DMA channel 4"},
              {"name": "LPD_DMA_CH5", "addr": "0xffad0000", "size": "64K", "altname": "ADMA_CH5", "nodeid": "0x1822403a", "smid": "LPD_DMA_CH5", "type": "manager", "desc": "General purpose DMA channel 5"},
              {"name": "LPD_DMA_CH6", "addr": "0xffae0000", "size": "64K", "altname": "ADMA_CH6", "nodeid": "0x1822403b", "smid": "LPD_DMA_CH6", "type": "manager", "desc": "General purpose DMA channel 6"},
              {"name": "LPD_DMA_CH7", "addr": "0xffaf0000", "size": "64K", "altname": "ADMA_CH7", "nodeid": "0x1822403c", "smid": "LPD_DMA_CH7", "type": "manager", "desc": "General purpose DMA channel 7"},
              {"name": "PSM_ICACHE_mem", "addr": "0xffc00000", "size": "128K", "mem": true, "desc": "PSM I-cache Addressable"},
              {"name": "PSM_DCACHE_mem", "addr": "0xffc20000", "size": "128K", "mem": true, "desc": "PSM D-cache Addressable"},
              {"name": "PSM_IO", "addr": "0xffc80000", "size": "64K"},
              {"name": "PSM_IOMODULE", "addr": "0xffc80000", "size": "32K", "smid": "PSM", "type": "manager", "desc": "PSM I/O Module registers"},
              {"name": "PSM_LOCAL", "addr": "0xffc88000", "size": "32K", "altname": "PSM_LOCAL_REG", "desc": "PSM Local registers"},
              {"name": "PSM_GLOBAL", "addr": "0xffc90000", "size": "64K", "altname": "PSM_GLOBAL_REG", "desc": "PSM Global registers"},
              {"name": "PSM_INT_GPV", "addr": "0xffc9f000", "size": "4K", "desc": "PSM Interconnect Global Programmers View (GPV)"},
              {"name": "PSM_ICACHE_ECC", "addr": "0xffca0000", "size": "64K", "altname": "PSM_RAM_INSTR_ECC_CTRL", "desc": "PSM I-cache ECC control"},
              {"name": "PSM_DCACHE_ECC", "addr": "0xffcb0000", "size": "64K", "altname": "PSM_RAM_DATA_ECC_CTRL", "desc": "PSM D-cache ECC control"},
              {"name": "PSM_TMR_MANAGER", "addr": "0xffcc0000", "size": "64K", "desc": "PSM Triple Redundancy Manager"},
              {"name": "PSM_TMR_INJECT", "addr": "0xffcd0000", "size": "64K", "desc": "PSM Triple Redundancy Error Injection"},
              {"name": "PSM_TMR_TRACE", "addr": "0xffce0000", "size": "64K", "desc": "PSM Trace Module control"},
              {"name": "PSM_MDM", "addr": "0xffcf0000", "size": "64K", "altname": "PSM_MDM_HSD", "desc": "PSM Debug Module control"},
              {"name": "RPU_Memory", "addr": "0xffe00000", "size": "1M"},
              {"name": "RPU0_TCMA_mem", "addr": "0xffe00000", "size": "64K", "mem": true, "nodeid": "0x1831800b", "desc": "RPU0 TCM A lock-step and dual modes"},
              {"name": "RPU0_TCMA_mem_lockstep", "addr": "0xffe10000", "size": "64K", "mem": true, "desc": "RPU0 TCM A lock-step mode"},
              {"name": "RPU0_TCMB_mem", "addr": "0xffe20000", "size": "64K", "mem": true, "nodeid": "0x1831800c", "desc": "RPU0 TCM B lock-step and dual modes"},
              {"name": "RPU0_TCMB_mem_lockstep", "addr": "0xffe30000", "size": "64K", "mem": true, "desc": "RPU0 TCM B lock-step mode"},
              {"name": "RPU0_iCACHE_mem", "addr": "0xffe40000", "size": "32K", "mem": true, "desc": "RPU0 instruction cache lock-step and dual modes"},
              {"name": "RPU0_dCACHE_mem", "addr": "0xffe50000", "size": "32K", "mem": true, "desc": "RPU0 data cache lock-step and dual modes"},
              {"name": "RPU1_TCMA_mem_dual", "addr": "0xffe90000", "size": "64K", "mem": true, "nodeid": "0x1831800d", "desc": "RPU1 TCM A dual mode"},
              {"name": "RPU1_TCMB_mem_dual", "addr": "0xffeb0000", "size": "64K", "mem": true, "nodeid": "0x1831800e", "desc": "RPU1 TCM B dual mode"},
              {"name": "RPU1_iCACHE_mem_dual", "addr": "0xffec0000", "size": "32K", "mem": true, "desc": "RPU1 instruction cache dual mode"},
              {"name": "RPU1_dCACHE_mem_dual", "addr": "0xffed0000", "size": "32K", "mem": true, "desc": "RPU1 data cache dual mode"},
              {"name": "OCM_mem", "addr": "0xfffc0000", "size": "256K", "mem": true, "nodeid": "0x18900008", "xmpu": "OCM_XMPU", "desc": "On-chip Memory space"},
              {"name": "OCM0_mem", "addr": "0xfffc0000", "size": "64K", "mem": true, "nodeid": "0x18314007"},
              {"name": "OCM1_mem", "addr": "0xfffd0000", "size": "64K", "mem": true, "nodeid": "0x18314008"},
              {"name": "OCM2_mem", "addr": "0xfffe0000", "size": "64K", "mem": true, "nodeid": "0x18314009"},
              {"name": "OCM3_mem", "addr": "0xffff0000", "size": "64K", "mem": true, "nodeid": "0x1831400a"},
              {"name": "PL_LOW", "addr": "0x20100000000", "size": "2044G", "mem": true, "constants": {"pl": true}},
              {"name": "PL_HIGH", "addr": "0x80000000000", "size": "8192G", "mem": true, "constants": {"pl": true}}
            ]
          }
        }
      },
      "ulp": {
        "type": "bdc",
        "SMIDs": [
          {"ref": "BLP_M_M00_INI_0", "value": "0x13", "count": 1},
          {"ref": "BLP_M_M01_INI_0", "value": "0x14", "count": 1}
        ]
      }
    },
    "base_protection": {
      "access": [
        {"same_as_default": "firmware_and_cci"},
        {"same_as_default": "firmware_and_cci.debug"},
        {"same_as_default": "firmware"},
        {"same_as_default": "firmware.debug"},
        {"same_as_default": "open_rw"},
        {"same_as_default": "open_rw_fpd"},
        {"same_as_default": "open_ro"},
        {"same_as_default": "open_ro_2"},
        {"same_as_default": "apu_rw"},
        {"same_as_default": "bootmedia"},
        {"same_as_default": "bootmedia_pmc"},
        {"same_as_default": "PLM_image_store"},
        {
          "name": "prot_status",
          "destinations": ["LPD_XPPU", "OCM_XMPU", "PMC_XPPU_NPI_64KB_apertures", "PSM_GLOBAL"],
          "SMIDs": ["APU0", "RPU0"]
        },
        {
          "name": "cpu_rw",
          "destinations": ["CRL_0"],
          "SMIDs": ["APU0", "RPU0"]
        },
        {
          "name": "rpu_rw",
          "destinations": ["PMC_GLOBAL", "PMC_IOP_SLCR", "PMC_IOP_SLCR_SECURE", "PMC_JTAG_CSR"],
          "SMIDs": ["RPU0"]
        }
      ],
      "units": {
        "/blp/axi_noc_mc_1x/ddrmc": {
          "root_access": "firmware_and_cci",
          "flags": {"enable": true, "hide_en": true, "lock": true}
        },
        "FPD_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "IPI": {
          "flags": {"enable": true, "hide_error": true, "lock": true, "slverr_enable": true}
        },
        "IPI_PERM": {
          "flags": {}
        },
        "LPD_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "OCM_XMPU": {
          "root_access": "firmware_and_cci",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "PLM": {
          "flags": {}
        },
        "PMC_EM": {
          "flags": {}
        },
        "PMC_XMPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XPPU": {
          "root_access": "firmware",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "PMC_XPPU_NPI": {
          "root_access": "firmware",
          "flags": {"enable": true, "hide_en": true, "interrupt_enable": true, "lock": true}
        },
        "PSM_EM": {
          "flags": {}
        },
        "SECURE_REG_ACCESS": {
          "root_access": "",
          "flags": {}
        },
        "SW_EM": {
          "flags": {}
        },
        "XRAM_XMPU0": {
          "root_access": "",
          "flags": {}
        },
        "XRAM_XMPU1": {
          "root_access": "",
          "flags": {}
        },
        "XRAM_XMPU2": {
          "root_access": "",
          "flags": {}
        },
        "XRAM_XMPU3": {
          "root_access": "",
          "flags": {}
        }
      }
    },
    "subsystems": {
      "Non_secure": {
        "id": "0x1c000006",
        "access": [
          {
            "name": "cpus_0",
            "type": "cpu_list",
            "SMIDs": ["APU0"]
          },
          {
            "name": "ns_strict_xmpu_apu",
            "destinations": ["ddr_reg_0"],
            "SMIDs": ["APU0"]
          },
          {
            "name": "ns_strict_xmpu_apu_ocm",
            "destinations": ["OCM_mem"],
            "SMIDs": ["APU0"]
          },
          {
            "name": "ns_shared_xmpu_apu_rpu",
            "destinations": ["ddr_reg_2"],
            "SMIDs": ["APU0", "RPU0"]
          },
          {
            "name": "ns_shared_xmpu_apu_rpu_pf1",
            "destinations": ["ddr_reg_1"],
            "SMIDs": ["/blp/axi_noc_ic/S07_AXI", "APU0", "RPU0"]
          },
          {
            "name": "ns_shared_xmpu_apu_dma",
            "destinations": ["ddr_reg_5"],
            "SMIDs": ["/blp/axi_noc_ic/S06_AXI", "APU0"]
          },
          {
            "name": "ns_shared_xmpu_aie_pl_dma",
            "destinations": ["ddr_reg_6"],
            "SMIDs": ["/ulp/BLP_M_M00_INI_0", "/ulp/BLP_M_M01_INI_0", "/blp/axi_noc_ic/S06_AXI", "AIE", "APU0", "RPU0"]
          },
          {
            "name": "ns_strict_xppu_apu",
            "destinations": [
              "LPD_GPIO",
              "LPD_I2C0",
              "PMC_RTC",
              "SPI0",
              "TTC2",
              "TTC3",
              "UART1"
            ],
            "SMIDs": ["APU0"]
          },
          {
            "name": "ipi_apu",
            "destinations": ["IPI0", "IPI1", "IPI2", "IPI5", "IPI6"],
            "SMIDs": ["APU0"]
          }
        ]
      },
      "Secure": {
        "id": "0x1c000007",
        "access": [
          {
            "name": "cpus_0",
            "type": "cpu_list",
            "flags": {"secure": true},
            "SMIDs": ["RPU0"]
          },
          {
            "name": "secure_xmpu_rpu",
            "destinations": ["ddr_reg_4"],
            "flags": {"secure": true},
            "SMIDs": ["OSPI", "PMC", "RPU0"]
          },
          {
            "name": "secure_xppu",
            "destinations": [
              "PMC_GPIO",
              "PMC_I2C",
              "RPU0_TCMA_mem",
              "TTC0",
              "TTC1",
              "UART0"
            ],
            "flags": {"secure": true},
            "SMIDs": ["RPU0"]
          },
          {
            "name": "ns_pmc_xppu_rpu",
            "destinations": ["OSPI", "PMC_SYSMON_CSR"],
            "SMIDs": ["RPU0"]
          },
          {
            "name": "ns_boot_rpu",
            "destinations": ["PMC_OSPI_mem"],
            "SMIDs": ["RPU0"]
          },
          {
            "name": "secure_pmc_xmpu",
            "destinations": ["PMC_XMPU_mem"],
            "flags": {"secure": true},
            "SMIDs": ["RPU0"]
          },
          {
            "name": "secure_share_xmpu_rpu_pf0",
            "destinations": ["ddr_reg_3"],
            "flags": {"secure": true},
            "SMIDs": ["/blp/axi_noc_ic/S07_AXI", "RPU0"]
          },
          {
            "name": "ipi_rpu",
            "destinations": ["IPI3", "IPI4"],
            "flags": {"secure": true},
            "SMIDs": ["RPU0"]
          }
        ]
      },
      "default": {
        "id": "0x1c000000",
        "flags": {"ignore": true},
        "access": [
          {"same_as_default": "cpus"},
          {"same_as_default": "secure_cpus"},
          {"same_as_default": "uart"},
          {"same_as_default": "gem"},
          {"same_as_default": "mem_ctrl"},
          {"same_as_default": "mem"},
          {"same_as_default": "bootmedia"},
          {"same_as_default": "OSPI_mem"},
          {"same_as_default": "non_secure"},
          {"same_as_default": "ipi0"},
          {"same_as_default": "ipi1"},
          {"same_as_default": "ipi2"},
          {"same_as_default": "ipi5"},
          {"same_as_default": "ipi_unused"},
          {"same_as_default": "resets"},
          {"same_as_default": "not_requested_secure"},
          {"same_as_default": "ggs_pggs"},
          {"same_as_default": "not_requested_mgr"},
          {"same_as_default": "not_requested_fpd"},
          {"same_as_default": "not_requested_mem"},
          {"same_as_default": "not_requested"}
        ]
      }
    }
  }
}
