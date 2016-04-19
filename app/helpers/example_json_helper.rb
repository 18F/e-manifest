module ExampleJsonHelper
  def example_json_root_path
    "#{Pathname.new(__FILE__).dirname}/../views/examples"
  end

  def example_json_file_path(name)
    "#{example_json_root_path}/_#{name}.json"
  end

  def read_example_json_file(name)
    File.read(example_json_file_path(name))
  end

  def read_example_json_file_as_json(name)
    JSON.parse(read_example_json_file(name))
  end

  def random_tracking_number
    num = '%09d' % SecureRandom.random_number(1_000_000_000)
    str = (0...3).map { (65 + rand(26)).chr }.join
    "#{num}#{str}"
  end 
end
