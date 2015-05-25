module PacketsAtRest
    module Filer
        class FileLockError < StandardError; end
        class FileLockPermissionsError < StandardError; end

        class Filer
            attr_reader :lockfile, :capturedir, :fileprefix, :filerdir, :simulate

            # major note .. need to check if utc is a problem here
            attr_accessor :utc

            def initialize(opts = {})

                @lockfile = opts[:lockfile] || PacketsAtRest::LOCKFILE
                @capturedir = opts[:capturedir] || PacketsAtRest::CAPTUREDIR
                @fileprefix = opts[:fileprefix] || PacketsAtRest::FILEPREFIX
                @filerdir = opts[:filerdir] || PacketsAtRest::FILERDIR
                @simulate= opts[:simulate] || false
                @autoclean =  opts[:autoclean] || false
                @utc = opts[:utc] || PacketsAtRest::UTC

                io = opts[:logger_io] || STDOUT

                @logger = ::Logger.new(io)
                @logger.level = opts[:logger_level] || Logger::DEBUG

            end

            def file_pcaps()
                @logger.info("Program started.")
                begin
                    _file_lock
                    _moved_files = []
                    _file_list.each do |filepath|
                      newfilepath = _build_newpath(filepath)
                      @logger.info "Moving #{filepath} => #{newfilepath} "
                      _move(filepath, newfilepath)
                      _moved_files << newfilepath
                    end
                    FileUtils.rm_f @lockfile
                    @logger.info("#{lockfile} removed.")
                ensure
                    begin
                      if @autoclean
                        FileUtils.rm_f @lockfile if File.file?(@lockfile)
                        @logger.info("#{lockfile} removed.")
                      end
                    rescue
                      @logger.info("#{lockfile} problem.")
                    end
                    @logger.info("Program completed.")
                end
                return _moved_files
            end

            def locked?
                @locked || File.file?(@lockfile)
            end

            private

            # Pesimistic File Locking
            def _file_lock
                @locked = false
                raise FileLockError, 'Lockfile in use.' if File.file?(@lockfile)
                FileUtils.touch @lockfile
                raise FileLockError, 'Lockfile not created.' unless File.file?(@lockfile)
                raise FileLockPermissionsError, 'Lock file not writable.' unless File.stat(@lockfile).writable?
                @locked = true
                return @locked
            end

            def _file_list
                @logger.info("scanning #{@capturedir}/#{@fileprefix}.*")
                file_list = Dir["#{@capturedir}/#{@fileprefix}.*"]
                return file_list.sort[0...-1]
            end

            def _move(oldpath, newpath)
              FileUtils.mkdir_p(newpath) unless @simulate
              FileUtils.mv(oldpath, newpath) unless @simulate
            rescue => err
              @logger.warn("Caught exception while doing file operations: #{err.message}")
            end

            def _build_newpath(filepath)
                datetime = _build_datetime(filepath)
                return "#{@filerdir}/#{datetime.year}/#{datetime.month.pad2}/#{datetime.day.pad2}/#{datetime.hour.pad2}/"
            end

            def _build_datetime(filepath)
                file = File.basename(filepath)

                # major note .. need to check if utc is a problem here
                @logger.info ("Processing: #{file}")
                unixtime = file.sub(/#{@fileprefix}\./, '').to_i

                # should this be Time.at(unixtime).utc ??
                return Time.at(unixtime)

            end
        end
    end
end
