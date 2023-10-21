group "default" {
  targets = ["yamllint", "hadolint", "shellcheck"]
}

target "_lint" {
  dockerfile = "lint.Dockerfile"
  output = ["type=cacheonly"]
}

target "hadolint" {
  inherits = ["_lint"]
  target = "hadolint"
}

target "shellcheck" {
  inherits = ["_lint"]
  target = "shellcheck"
}

target "yamllint" {
  inherits = ["_lint"]
  target = "yamllint"
}
