class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    "api/documentation/#{path}"
  end
end

Swagger::Docs::Config.register_apis({
  '1.0' => {
    controller_base_path: '',
    api_file_path: 'public/api/documentation',
    base_path: 'localhost:3000',
    clean_directory: true
  }
})
