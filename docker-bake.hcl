target "default" {
  target = "hadolint"
  dockerfile = "check.Dockerfile"
  no-cache = true
  output = ["type=cacheonly"]
}
