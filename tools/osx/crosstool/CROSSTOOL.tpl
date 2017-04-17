major_version: "1"
minor_version: "0"
default_target_cpu: "ios_x86_64"
default_toolchain {
  cpu: "darwin"
  toolchain_identifier: "darwin_x86_64"
}
default_toolchain {
  cpu: "darwin_x86_64"
  toolchain_identifier: "darwin_x86_64"
}
default_toolchain {
  cpu: "k8"
  toolchain_identifier: "darwin_x86_64"
}
default_toolchain {
  cpu: "ios_x86_64"
  toolchain_identifier: "ios_x86_64"
}
default_toolchain {
  cpu: "ios_i386"
  toolchain_identifier: "ios_i386"
}
default_toolchain {
  cpu: "ios_armv7"
  toolchain_identifier: "ios_armv7"
}
default_toolchain {
  cpu: "ios_arm64"
  toolchain_identifier: "ios_arm64"
}
default_toolchain {
  cpu: "watchos_i386"
  toolchain_identifier: "watchos_i386"
}
default_toolchain {
  cpu: "watchos_armv7k"
  toolchain_identifier: "watchos_armv7k"
}
default_toolchain {
  cpu: "tvos_x86_64"
  toolchain_identifier: "tvos_x86_64"
}
default_toolchain {
  cpu: "tvos_arm64"
  toolchain_identifier: "tvos_arm64"
}
default_toolchain {
  cpu: "armeabi-v7a"
  toolchain_identifier: "stub_armeabi-v7a"
}
toolchain {
  toolchain_identifier: "darwin_x86_64"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "x86_64-apple-macosx"
  target_cpu: "darwin_x86_64"
  target_libc: "macosx"
  compiler: "compiler"
  abi_version: "darwin_x86_64"
  abi_libc_version: "darwin_x86_64"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_MACOSX"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "link_cocoa"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Cocoa"
      }
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "ios_x86_64"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "x86_64-apple-ios"
  target_cpu: "ios_x86_64"
  target_libc: "ios"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "x86_64-apple-ios"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "x86_64-apple-ios"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "apply_simulator_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fexceptions"
        flag: "-fasm-blocks"
        flag: "-fobjc-abi-version=2"
        flag: "-fobjc-legacy-dispatch"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mios-simulator-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "watchos_i386"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "i386-apple-watchos"
  target_cpu: "watchos_i386"
  target_libc: "watchos"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "i386-apple-ios"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "i386-apple-watchos"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "apply_simulator_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fexceptions"
        flag: "-fasm-blocks"
        flag: "-fobjc-abi-version=2"
        flag: "-fobjc-legacy-dispatch"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
        flag: "-F%{sdk_framework_dir}"
        flag: "-F%{platform_developer_framework_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mwatchos-simulator-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "i386"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "i386"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "tvos_x86_64"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "x86_64-apple-tvos"
  target_cpu: "tvos_x86_64"
  target_libc: "tvos"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "x86_64-apple-tvos"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
    compiler_flag: "-DNS_BLOCK_ASSERTIONS=1"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "x86_64-apple-tvos"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_TVOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "apply_simulator_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fexceptions"
        flag: "-fasm-blocks"
        flag: "-fobjc-abi-version=2"
        flag: "-fobjc-legacy-dispatch"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "cpp_linker_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-lc++"
        flag: "-undefined"
        flag: "dynamic_lookup"
        flag: "-target"
        flag: "x86_64-apple-tvos"
      }
    }
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "unfiltered_cxx_flags"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-no-canonical-prefixes"
        flag: "-pthread"
      }
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mtvos-simulator-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
    implies: "cpp_linker_flags"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
    implies: "cpp_linker_flags"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "x86_64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "x86_64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "ios_i386"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "i386-apple-ios"
  target_cpu: "ios_i386"
  target_libc: "ios"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "i386-apple-ios"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "i386-apple-ios"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "apply_simulator_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fexceptions"
        flag: "-fasm-blocks"
        flag: "-fobjc-abi-version=2"
        flag: "-fobjc-legacy-dispatch"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mios-simulator-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "i386"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "apply_simulator_compiler_flags"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "i386"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "i386"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "ios_armv7"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "armv7-apple-ios"
  target_cpu: "ios_armv7"
  target_libc: "ios"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "armv7-apple-ios"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "armv7-apple-ios"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-miphoneos-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "armv7"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "armv7"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "armv7"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "watchos_armv7k"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "armv7-apple-watchos"
  target_cpu: "watchos_armv7k"
  target_libc: "watchos"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "armv7-apple-watchos"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "armv7k-apple-watchos"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
        flag: "-F%{sdk_framework_dir}"
        flag: "-F%{platform_developer_framework_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mwatchos-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7k"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "armv7k"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "armv7k"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7k"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "armv7k"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "armv7k"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "tvos_arm64"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "arm64-apple-tvos"
  target_cpu: "tvos_arm64"
  target_libc: "tvos"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "arm64-apple-tvos"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
    compiler_flag: "-DNS_BLOCK_ASSERTIONS=1"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "arm64-apple-tvos"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_TVOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "cpp_linker_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-lc++"
        flag: "-undefined"
        flag: "dynamic_lookup"
        flag: "-target"
        flag: "arm64-apple-tvos"
      }
    }
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "unfiltered_cxx_flags"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-no-canonical-prefixes"
        flag: "-pthread"
      }
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-mtvos-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
    implies: "cpp_linker_flags"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
    implies: "cpp_linker_flags"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "arm64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "arm64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
    implies: "unfiltered_cxx_flags"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "ios_arm64"
  host_system_name: "x86_64-apple-macosx"
  target_system_name: "arm64-apple-ios"
  target_cpu: "ios_arm64"
  target_libc: "ios"
  compiler: "compiler"
  abi_version: "local"
  abi_libc_version: "local"
  tool_path {
    name: "ar"
    path: "/usr/bin/libtool"
  }
  tool_path {
    name: "compat-ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "cpp"
    path: "/usr/bin/cpp"
  }
  tool_path {
    name: "dwp"
    path: "/usr/bin/dwp"
  }
  tool_path {
    name: "gcc"
    path: "cc_wrapper.sh"
  }
  tool_path {
    name: "gcov"
    path: "/usr/bin/gcov"
  }
  tool_path {
    name: "ld"
    path: "/usr/bin/ld"
  }
  tool_path {
    name: "nm"
    path: "/usr/bin/nm"
  }
  tool_path {
    name: "objcopy"
    path: "/usr/bin/objcopy"
  }
  tool_path {
    name: "objdump"
    path: "/usr/bin/objdump"
  }
  tool_path {
    name: "strip"
    path: "/usr/bin/strip"
  }
  needsPic: false
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  linker_flag: "-target"
  linker_flag: "arm64-apple-ios"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  unfiltered_cxx_flag: "-target"
  unfiltered_cxx_flag: "arm64-apple-ios"
  default_python_version: "python2.7"
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-miphoneos-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "arm64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "arm64"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "arm64"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
toolchain {
  toolchain_identifier: "stub_armeabi-v7a"
  host_system_name: "armeabi-v7a"
  target_system_name: "armeabi-v7a"
  target_cpu: "armeabi-v7a"
  target_libc: "armeabi-v7a"
  compiler: "compiler"
  abi_version: "armeabi-v7a"
  abi_libc_version: "armeabi-v7a"
  tool_path {
    name: "ar"
    path: "/bin/false"
  }
  tool_path {
    name: "compat-ld"
    path: "/bin/false"
  }
  tool_path {
    name: "cpp"
    path: "/bin/false"
  }
  tool_path {
    name: "dwp"
    path: "/bin/false"
  }
  tool_path {
    name: "gcc"
    path: "/bin/false"
  }
  tool_path {
    name: "gcov"
    path: "/bin/false"
  }
  tool_path {
    name: "ld"
    path: "/bin/false"
  }
  tool_path {
    name: "nm"
    path: "/bin/false"
  }
  tool_path {
    name: "objcopy"
    path: "/bin/false"
  }
  tool_path {
    name: "objdump"
    path: "/bin/false"
  }
  tool_path {
    name: "strip"
    path: "/bin/false"
  }
  supports_gold_linker: false
  needsPic: true
  compiler_flag: "-D_FORTIFY_SOURCE=1"
  compiler_flag: "-fstack-protector"
  compiler_flag: "-fcolor-diagnostics"
  compiler_flag: "-Wall"
  compiler_flag: "-Wthread-safety"
  compiler_flag: "-Wself-assign"
  compiler_flag: "-fno-omit-frame-pointer"
  cxx_flag: "-std=c++11"
  linker_flag: "-undefined"
  linker_flag: "dynamic_lookup"
  linker_flag: "-headerpad_max_install_names"
  linker_flag: "-no-canonical-prefixes"
  objcopy_embed_flag: "-I"
  objcopy_embed_flag: "binary"
  compilation_mode_flags {
    mode: FASTBUILD
    compiler_flag: "-O0"
    compiler_flag: "-DDEBUG"
  }
  compilation_mode_flags {
    mode: DBG
    compiler_flag: "-g"
  }
  compilation_mode_flags {
    mode: OPT
    compiler_flag: "-g0"
    compiler_flag: "-O2"
    compiler_flag: "-D_FORTIFY_SOURCE=1"
    compiler_flag: "-DNDEBUG"
    compiler_flag: "-ffunction-sections"
    compiler_flag: "-fdata-sections"
    compiler_flag: "-DNS_BLOCK_ASSERTIONS=1"
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  linking_mode_flags {
    mode: DYNAMIC
  }
  make_variable {
    name: "STACK_FRAME_UNLIMITED"
    value: "-Wframe-larger-than=100000000 -Wno-vla"
  }
  cxx_builtin_include_directory: "/"
  builtin_sysroot: ""
  unfiltered_cxx_flag: "-no-canonical-prefixes"
  unfiltered_cxx_flag: "-Wno-builtin-macro-redefined"
  unfiltered_cxx_flag: "-D__DATE__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIMESTAMP__=\"redacted\""
  unfiltered_cxx_flag: "-D__TIME__=\"redacted\""
  supports_normalizing_ar: false
  supports_start_end_lib: false
  default_python_version: "python2.7"
  supports_interface_shared_objects: false
  supports_incremental_linker: false
  supports_fission: false
  ar_flag: "-static"
  ar_flag: "-s"
  ar_flag: "-o"
  feature {
    name: "apple_env"
    env_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-archive"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      action: "objc-executable"
      action: "objc++-executable"
      env_entry {
        key: "XCODE_VERSION_OVERRIDE"
        value: "%{xcode_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_VERSION_OVERRIDE"
        value: "%{apple_sdk_version_override_value}"
      }
      env_entry {
        key: "APPLE_SDK_PLATFORM"
        value: "%{apple_sdk_platform_value}"
      }
    }
  }
  feature {
    name: "apply_default_compiler_flags"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-DOS_IOS"
      }
    }
  }
  feature {
    name: "apply_default_warnings"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-Wshorten-64-to-32"
        flag: "-Wbool-conversion"
        flag: "-Wconstant-conversion"
        flag: "-Wduplicate-method-match"
        flag: "-Wempty-body"
        flag: "-Wenum-conversion"
        flag: "-Wint-conversion"
        flag: "-Wunreachable-code"
        flag: "-Wmismatched-return-types"
        flag: "-Wundeclared-selector"
        flag: "-Wuninitialized"
        flag: "-Wunused-function"
        flag: "-Wunused-variable"
      }
    }
  }
  feature {
    name: "apply_implicit_frameworks"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-framework Foundation"
        flag: "-framework UIKit"
      }
    }
  }
  feature {
    name: "bitcode_embedded"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode"
      }
    }
  }
  feature {
    name: "bitcode_embedded_markers"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fembed-bitcode-marker"
      }
    }
  }
  feature {
    name: "cc_archiver_flags"
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "rcs"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
      expand_if_all_available: "uses_action_configs_for_cc_archiver"
    }
  }
  feature {
    name: "compile_all_modules"
  }
  feature {
    name: "coverage"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    flag_set {
      action: "c++-link-interface-dynamic-library"
      action: "c++-link-dynamic-library"
      action: "c++-link-executable"
      flag_group {
        flag: "-fprofile-instr-generate"
      }
    }
    provides: "profile"
  }
  feature {
    name: "dbg"
  }
  feature {
    name: "dead_strip"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "--dead_strip"
        flag: "--no_dead_strip_inits_and_terms"
      }
    }
    requires {
      feature: "opt"
    }
  }
  feature {
    name: "exclude_private_headers_in_module_maps"
  }
  feature {
    name: "fastbuild"
  }
  feature {
    name: "force_pic_flags"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-pie"
      }
      expand_if_all_available: "force_pic"
    }
  }
  feature {
    name: "framework_paths"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-F%{framework_paths}"
      }
    }
  }
  feature {
    name: "gcc_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-arcs"
        flag: "-ftest-coverage"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "global_whole_archive_open"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-all_load"
      }
      expand_if_all_available: "global_whole_archive"
    }
  }
  feature {
    name: "has_configured_linker_path"
  }
  feature {
    name: "include_system_dirs"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "objc-compile"
      action: "objc++-compile"
      action: "objc-executable"
      action: "objc++-executable"
      action: "assemble"
      action: "preprocess-assemble"
      flag_group {
        flag: "-isysroot %{sdk_dir}"
      }
    }
  }
  feature {
    name: "input_param_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-L%{library_search_directories}"
        iterate_over: "library_search_directories"
      }
      expand_if_all_available: "library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{libopts}"
      }
      expand_if_all_available: "libopts"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-force_load,%{whole_archive_linker_params}"
      }
      expand_if_all_available: "whole_archive_linker_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{linker_input_params}"
      }
      expand_if_all_available: "linker_input_params"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag_group {
          flag: "-Wl,--start-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.object_files}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.object_files}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          iterate_over: "libraries_to_link.object_files"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag: "-Wl,--end-lib"
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file_group"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "object_file"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "interface_library"
          }
        }
        flag_group {
          flag_group {
            flag: "%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "static_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "dynamic_library"
          }
        }
        flag_group {
          flag_group {
            flag: "-l:%{libraries_to_link.name}"
            expand_if_false: "libraries_to_link.is_whole_archive"
          }
          flag_group {
            flag: "-Wl,-force_load,-l:%{libraries_to_link.name}"
            expand_if_true: "libraries_to_link.is_whole_archive"
          }
          expand_if_equal {
            variable: "libraries_to_link.type"
            value: "versioned_dynamic_library"
          }
        }
        iterate_over: "libraries_to_link"
      }
      expand_if_all_available: "libraries_to_link"
    }
  }
  feature {
    name: "legacy_link_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "%{legacy_link_flags}"
        iterate_over: "legacy_link_flags"
      }
      expand_if_all_available: "legacy_link_flags"
    }
  }
  feature {
    name: "linker_param_file"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
    flag_set {
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "@%{linker_param_file}"
      }
      expand_if_all_available: "linker_param_file"
    }
  }
  feature {
    name: "linkstamps"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "%{linkstamp_paths}"
      }
      expand_if_all_available: "linkstamp_paths"
    }
  }
  feature {
    name: "llvm_coverage_map_format"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fprofile-instr-generate"
        flag: "-fcoverage-mapping"
      }
    }
    requires {
      feature: "run_coverage"
    }
  }
  feature {
    name: "module_maps"
  }
  feature {
    name: "no_enable_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-maps"
      }
    }
    requires {
      feature: "use_objc_modules"
    }
  }
  feature {
    name: "no_objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fno-objc-arc"
      }
      expand_if_all_available: "no_objc_arc"
    }
  }
  feature {
    name: "objc_actions"
    implies: "objc-compile"
    implies: "objc++-compile"
    implies: "objc-fully-link"
    implies: "objc-archive"
    implies: "objc-executable"
    implies: "objc++-executable"
    implies: "assemble"
    implies: "preprocess-assemble"
    implies: "c-compile"
    implies: "c++-compile"
    implies: "c++-link-static-library"
    implies: "c++-link-pic-static-library"
    implies: "c++-link-interface-dynamic-library"
    implies: "c++-link-dynamic-library"
    implies: "c++-link-alwayslink-static-library"
    implies: "c++-link-alwayslink-pic-static-library"
    implies: "c++-link-executable"
  }
  feature {
    name: "objc_arc"
    flag_set {
      action: "c-compile"
      action: "c++-compile"
      action: "c++-module-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "assemble"
      action: "preprocess-assemble"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fobjc-arc"
      }
      expand_if_all_available: "objc_arc"
    }
  }
  feature {
    name: "only_doth_headers_in_module_maps"
  }
  feature {
    name: "opt"
  }
  feature {
    name: "output_execpath_flags"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-o"
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "output_execpath_flags_executable"
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "-o"
      }
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "/dev/null"
        flag: "-MMD"
        flag: "-MF"
      }
      expand_if_all_available: "skip_mostly_static"
      expand_if_all_available: "output_execpath"
    }
    flag_set {
      action: "c++-link-executable"
      flag_group {
        flag: "%{output_execpath}"
      }
      expand_if_all_available: "output_execpath"
    }
  }
  feature {
    name: "pch"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      action: "c-compile"
      action: "c++-compile"
      flag_group {
        flag: "-include"
        flag: "%{pch_file}"
      }
    }
  }
  feature {
    name: "preprocessor_defines"
    flag_set {
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-D%{preprocessor_defines}"
      }
    }
  }
  feature {
    name: "run_coverage"
  }
  feature {
    name: "runtime_root_flags"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}"
        iterate_over: "runtime_library_search_directories"
      }
      expand_if_all_available: "runtime_library_search_directories"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_flags}"
      }
      expand_if_all_available: "runtime_root_flags"
    }
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-static-library"
      action: "c++-link-alwayslink-static-library"
      action: "c++-link-pic-static-library"
      action: "c++-link-alwayslink-pic-static-library"
      flag_group {
        flag: "%{runtime_root_entries}"
      }
      expand_if_all_available: "runtime_root_entries"
    }
  }
  feature {
    name: "shared_flag"
    flag_set {
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-shared"
      }
    }
  }
  feature {
    name: "strip_debug_symbols"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "c++-link-interface-dynamic-library"
      action: "objc-executable"
      action: "objc++-executable"
      flag_group {
        flag: "-Wl,-S"
        expand_if_all_available: "strip_debug_symbols"
      }
    }
  }
  feature {
    name: "symbol_counts"
    flag_set {
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      flag_group {
        flag: "-Wl,--print-symbol-counts=%{symbol_counts_output}"
      }
      expand_if_all_available: "symbol_counts_output"
    }
  }
  feature {
    name: "use_objc_modules"
    flag_set {
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-fmodule-name=%{module_name}"
        flag: "-iquote"
        flag: "%{module_maps_dir}"
        flag: "-fmodules-cache-path=%{modules_cache_path}"
      }
    }
  }
  feature {
    name: "version_min"
    flag_set {
      action: "objc-executable"
      action: "objc++-executable"
      action: "c++-link-executable"
      action: "c++-link-dynamic-library"
      action: "preprocess-assemble"
      action: "c-compile"
      action: "c++-compile"
      action: "c++-header-parsing"
      action: "c++-header-preprocessing"
      action: "c++-module-compile"
      action: "objc-compile"
      action: "objc++-compile"
      flag_group {
        flag: "-m<platform_for_version_min>-version-min=%{version_min}"
      }
    }
  }
  action_config {
    config_name: "assemble"
    action_name: "assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "include_system_dirs"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-compile"
    action_name: "c++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-parsing"
    action_name: "c++-header-parsing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-header-preprocessing"
    action_name: "c++-header-preprocessing"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-pic-static-library"
    action_name: "c++-link-alwayslink-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-alwayslink-static-library"
    action_name: "c++-link-alwayslink-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-dynamic-library"
    action_name: "c++-link-dynamic-library"
    tool {
      tool_path: "wrapped_clang"
    }
    implies: "has_configured_linker_path"
    implies: "symbol_counts"
    implies: "shared_flag"
    implies: "linkstamps"
    implies: "output_execpath_flags"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-executable"
    action_name: "c++-link-executable"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "symbol_counts"
    implies: "linkstamps"
    implies: "output_execpath_flags_executable"
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "input_param_flags"
    implies: "force_pic_flags"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "linker_param_file"
    implies: "version_min"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-interface-dynamic-library"
    action_name: "c++-link-interface-dynamic-library"
    tool {
      tool_path: "DUMMY_TOOL"
    }
    implies: "strip_debug_symbols"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-pic-static-library"
    action_name: "c++-link-pic-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-link-static-library"
    action_name: "c++-link-static-library"
    tool {
      tool_path: "/usr/bin/ar"
    }
    implies: "global_whole_archive_open"
    implies: "runtime_root_flags"
    implies: "cc_archiver_flags"
    implies: "input_param_flags"
    implies: "linker_param_file"
    implies: "apple_env"
  }
  action_config {
    config_name: "c++-module-compile"
    action_name: "c++-module-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "c-compile"
    action_name: "c-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-compile"
    action_name: "objc++-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "<architecture>"
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
    }
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc++-executable"
    action_name: "objc++-executable"
    tool {
      tool_path: "wrapped_clang_pp"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-stdlib=libc++"
        flag: "-std=gnu++11"
      }
      flag_group {
        flag: "-arch"
        flag: "<architecture>"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-archive"
    action_name: "objc-archive"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-filelist"
        flag: "%{obj_list_path}"
        flag: "-arch_only"
        flag: "<architecture>"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{archive_path}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-compile"
    action_name: "objc-compile"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "<architecture>"
      }
    }
    implies: "objc_actions"
    implies: "apply_default_compiler_flags"
    implies: "apply_default_warnings"
    implies: "framework_paths"
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  action_config {
    config_name: "objc-executable"
    action_name: "objc-executable"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-arch"
        flag: "<architecture>"
      }
      flag_group {
        flag: "-Xlinker"
        flag: "-objc_abi_version"
        flag: "-Xlinker"
        flag: "2"
        flag: "-Xlinker"
        flag: "-rpath"
        flag: "-Xlinker"
        flag: "@executable_path/Frameworks"
        flag: "-fobjc-link-runtime"
        flag: "-ObjC"
      }
      flag_group {
        flag: "-framework %{framework_names}"
      }
      flag_group {
        flag: "-weak_framework %{weak_framework_names}"
      }
      flag_group {
        flag: "-l%{library_names}"
      }
      flag_group {
        flag: "-filelist %{filelist}"
      }
      flag_group {
        flag: "-o %{linked_binary}"
      }
      flag_group {
        flag: "-force_load %{force_load_exec_paths}"
      }
      flag_group {
        flag: "%{dep_linkopts}"
      }
      flag_group {
        flag: "-Wl,%{attr_linkopts}"
      }
    }
    implies: "include_system_dirs"
    implies: "framework_paths"
    implies: "version_min"
    implies: "legacy_link_flags"
    implies: "strip_debug_symbols"
    implies: "apple_env"
    implies: "apply_implicit_frameworks"
  }
  action_config {
    config_name: "objc-fully-link"
    action_name: "objc-fully-link"
    tool {
      tool_path: "libtool"
      execution_requirement: "requires-darwin"
    }
    flag_set {
      flag_group {
        flag: "-static"
        flag: "-arch_only"
        flag: "<architecture>"
        flag: "-syslibroot"
        flag: "%{sdk_dir}"
        flag: "-o"
        flag: "%{fully_linked_archive_path}"
      }
      flag_group {
        flag: "%{objc_library_exec_paths}"
      }
      flag_group {
        flag: "%{cc_library_exec_paths}"
      }
      flag_group {
        flag: "%{imported_library_exec_paths}"
      }
    }
    implies: "apple_env"
  }
  action_config {
    config_name: "preprocess-assemble"
    action_name: "preprocess-assemble"
    tool {
      tool_path: "wrapped_clang"
      execution_requirement: "requires-darwin"
    }
    implies: "preprocessor_defines"
    implies: "include_system_dirs"
    implies: "version_min"
    implies: "objc_arc"
    implies: "no_objc_arc"
    implies: "apple_env"
  }
  cc_target_os: "apple"
}
