
# Load shared and local configuration

load_config <- function() {
  
  # Read shared defaults
  default_file <- here::here("config", "default.yml")
  cfg <- yaml::read_yaml(default_file)
  
  # Apply local overrides, if available
  local_file <- here::here("config", "local.yml")
  
  if (file.exists(local_file)) {
    local_cfg <- yaml::read_yaml(local_file)
    cfg <- utils::modifyList(cfg, local_cfg)
  }
  
  # Resolve input/output paths
  resolve_path <- function(path) {
    path <- path.expand(path)
    
    is_absolute <- grepl("^(/|[A-Za-z]:[/\\\\])", path) ||
      startsWith(path, "\\\\")
    
    if (is_absolute) {
      return(path)
    }
    
    here::here(path)
  }
  
  cfg$paths$input_dir <- resolve_path(cfg$paths$input_dir)
  cfg$paths$output_dir <- resolve_path(cfg$paths$output_dir)
  
  return(cfg)
}
