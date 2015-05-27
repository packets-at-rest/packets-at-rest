module PacketsAtRest
    class InvalidHost < StandardError; end

    module Controllers

        class Node
            def initialize(opts = {})
                @filerdir = opts[:filerdir] || PacketsAtRest::FILERDIR
                @fileprefix = opts[:fileprefix] || PacketsAtRest::FILEPREFIX
            end


            def filelist(start_dt, end_dt)
              # ensure boundary minutes are included by subtracting/adding a minute

              @start_d, @adj_start_dt = _calculate_adjusted_start_d(start_dt)
              @end_d, @adj_end_dt = _calculate_adjusted_end_d(end_dt)

              dirs = _dir_listing
              files = []

              if dirs.first == dirs.last
                Dir["#{dirs.first}/*"].sort.each do |filepath|
                  files << filepath if _within_time_window?(filepath)
                end
              else
                Dir["#{dirs.first}/*"].sort.each do |filepath|

                  files << filepath if _within_time_window?(filepath)
                end
                dirs.to_a[1...-1].each do |dir|
                  Dir["#{dir}/*"].sort.each do |filepath|
                    files << filepath
                  end
                end
                Dir["#{dirs.last}/*"].sort.each do |filepath|
                  files << filepath if _within_time_window?(filepath)
                end
              end

              return files
            end

            private

            def _within_time_window?(filepath)
                _extract_unixtime(filepath) >= @adj_start_dt.to_i and _extract_unixtime(filepath) <= @adj_end_dt.to_i
            end

            def _extract_unixtime(filepath)
                file = File.basename(filepath)
                file.sub(/#{@fileprefix}\./, '').to_i
            end

            def _dir_listing
                dirs = []

                if @start_d == @end_d
                  (@adj_start_dt.hour .. @adj_end_dt.hour).each do |hour|
                    dirs << "#{@filerdir}/#{@adj_start_dt.year}/#{@adj_start_dt.month.pad2}/#{@adj_start_dt.day.pad2}/#{hour.pad2}/"
                  end
                else
                  (@adj_start_dt.hour .. 23).each do |hour|
                    dirs << "#{@filerdir}/#{@adj_start_dt.year}/#{@adj_start_dt.month.pad2}/#{@adj_start_dt.day.pad2}/#{hour.pad2}/"
                  end
                  (@start_d .. @end_d).to_a[1...-1].each do |date|
                    (0 .. 23).each do |hour|
                      dirs << "#{@filerdir}/#{date.year}/#{date.month.pad2}/#{date.day.pad2}/#{hour.pad2}/"
                    end
                  end
                  (0 .. @adj_end_dt.hour).each do |hour|
                    dirs << "#{@filerdir}/#{@adj_end_dt.year}/#{@adj_end_dt.month.pad2}/#{@adj_end_dt.day.pad2}/#{hour.pad2}/"
                  end
                end

                return dirs
            end

            # Subtract a minute for beginning window
            def _calculate_adjusted_start_d(dt)
                adj_dt = dt - 60
                return adj_dt.to_date, adj_dt
            end

            # Add One minute for ending window
            def _calculate_adjusted_end_d(dt)
                adj_dt = dt + 60
                return adj_dt.to_date, adj_dt
            end


        end
    end
end
