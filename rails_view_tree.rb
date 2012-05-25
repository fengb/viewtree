class RailsViewTree
  attr_reader :filename
  attr_reader :base_dir

  def initialize(views_dir, base_dir, name)
    @views_dir = views_dir
    @base_dir = base_dir
    @name = name
    @filename = File.join(views_dir, base_dir, name)
  end

  def self.from_abs(abs_name)
    views_dir = abs_name.sub(/^(.*views\/).*?$/, '\1')
    base_dir = File.dirname(abs_name).sub(views_dir, '')
    name = File.basename(abs_name)
    new(views_dir, base_dir, name)
  end

  def to_s
    File.join(@base_dir, @name)
  end

  def exist?
    File.exists?(@filename)
  end

  def flatline(recur='    ', pre='')
    if self.exist?
      val = ["#{pre}#{self.to_s}"]
      val.concat(subs.map{|sub| sub.flatline(recur, "#{recur}""#{pre}")})
      val
    else
      ["#{pre.gsub(' ', '~')}#{self.to_s}"]
    end
  end

  def partial_lines
    IO.readlines(@filename).select{|l| l =~ /render.*:partial/}
  end

  def partial_dir_file(line)
    raw_name = line.sub(/.*partial *=> *['"]([^'"]*)['"].*/, '\1')
    if raw_name =~ /\//
      dir, partial_name = raw_name.split('/')
    else
      dir = @base_dir
      partial_name = raw_name
    end
    [dir, "_#{partial_name.strip}.rhtml"]
  end

  def subs
    @subs ||= partial_lines.map{|l| self.class.new(@views_dir, *partial_dir_file(l))}
  end
end


puts RailsViewTree.from_abs(ARGV[0]).flatline
