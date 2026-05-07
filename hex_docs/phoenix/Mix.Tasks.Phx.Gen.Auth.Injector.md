# Mix.Tasks.Phx.Gen.Auth.Injector



## app_layout_menu_code_to_inject(binding, padding \\ 4, newline \\ "\n")

Menu code to inject into the application layout template.

## app_layout_menu_help_text(file_path, binding)

Instructions to provide the user when `app_layout_menu_inject/2` fails.

## app_layout_menu_inject(binding, template_str)

Injects a menu in the application layout

## config_inject(file, code_to_inject)

Injects configuration into `file`.

## inject_before_final_end(code, code_to_inject)

Injects snippet before the final end in a file

## inject_unless_contains(code, dup_check, inject_fn)

Injects code unless the existing code already contains `code_to_inject`

## mix_dependency_inject(mixfile, dependency)

Injects a dependency into the contents of mix.exs

## router_plug_help_text(file_path, binding)

Instructions to provide the user when `inject_router_plug/2` fails.

## router_plug_inject(file, binding)

Injects the fetch_current_scope_for_<schema> plug into router's browser pipeline

## test_config_help_text(file_path, hashing_library)

Instructions to provide the user when `test_config_inject/2` fails.

## test_config_inject(file, hashing_library)

Injects configuration for test environment into `file`.