module PacketsAtRest
    module Filer
        class CLI
            def self.invoke
                self.new
            end

            def initialize
                options = {}
                options[:utc] = PacketsAtRest::UTC
                options[:capturedir] = PacketsAtRest::CAPTUREDIR
                options[:filerdir] = PacketsAtRest::FILERDIR
                options[:fileprefix] = PacketsAtRest::FILEPREFIX
                options[:lockfile] = PacketsAtRest::LOCKFILE
                options[:simulate] = false

                opt_parser = OptionParser.new do |opt|
                  opt.banner = "Usage: filer [OPTIONS]"

                  opt.on("-c", "--capturedir", "Directory in which daemonlogger writes files", "  Default: #{options[:capturedir]}") do |value|
                    options[:capturedir] = value
                  end

                  opt.on("-f", "--filerdir", "Directory to which to move in PCAPs", "  Default: #{options[:filerdir]}") do |value|
                    options[:filerdir] = value
                  end

                  opt.on("-p", "--fileprefix", "Daemonlogger capture file prefix", "  Default: #{options[:fileprefix]}") do |value|
                    options[:fileprefix] = value
                  end

                  #  opt.on("-u", "--utc", "Print UTC time (zulu/greenwich)", "  Default: #{options[:utc]}") do |value|
                  #    options[:utc] = value
                  #  end

                  opt.separator " Other Options::"
                  opt.separator ""

                  opt.on("-l", "--lockfile", "Lock file", "  Default: #{options[:lockfile]}") do |value|
                    options[:lockfile] = value
                  end

                  opt.on("-S", "--Simulate", "Simulate moving the files", "  Default: #{options[:simulate]}") do
                    options[:simulate] = true
                  end

                  opt.on("-A", "--AutoClean", "Warning:: Automatically clean lockfile if you own permissions", "  Default: #{options[:simulate]}") do
                    options[:autoclean] = true
                  end

                  opt.on_tail("-h", "--help", "Display this screen") do
                    puts opt_parser
                    exit 0
                  end

                end

                #Verify the options
                begin
                #  raise unless ARGV.size > 0
                  opt_parser.parse!

                #If options fail display help
                #rescue Exception => e
                #  puts e.message
                #  puts e.backtrace.inspect
                rescue
                  puts opt_parser
                  exit
                end

                begin
                    filer = PacketsAtRest::Filer::Filer.new(options)
                    filer.file_pcaps
                rescue PacketsAtRest::Filer::FileLockPermissionsError
                    abort "Lockfile File Read Perrmission Error, check permissions on the lockfile file."
                rescue PacketsAtRest::Filer::FileLockError
                    abort "Lock File Error, another filer process may be running."
                end

            end
        end
    end
end
