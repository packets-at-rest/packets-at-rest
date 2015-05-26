module PacketsAtRest
    module Controllers
        class Node
            def initialize(opts = {})
                @filerdir = opts[:apifile] || PacketsAtRest::FILERDIR
                @fileprefix = opts[:nodefile] || PacketsAtRest::FILEPREFIX
            end

            def filelist(start_dt, end_dt)
              # ensure boundary minutes are included by subtracting/adding a minute
              adj_start_dt = start_dt - 60
              adj_end_dt = end_dt + 60

              start_d = adj_start_dt.to_date
              end_d = adj_end_dt.to_date

              dirs = []

              if start_d == end_d
                (adj_start_dt.hour .. adj_end_dt.hour).each do |hour|
                  dirs << "#{@filerdir}/#{adj_start_dt.year}/#{adj_start_dt.month.pad2}/#{adj_start_dt.day.pad2}/#{hour.pad2}/"
                end
              else
                (adj_start_dt.hour .. 23).each do |hour|
                  dirs << "#{@filerdir}/#{adj_start_dt.year}/#{adj_start_dt.month.pad2}/#{adj_start_dt.day.pad2}/#{hour.pad2}/"
                end
                (start_d .. end_d).to_a[1...-1].each do |date|
                  (0 .. 23).each do |hour|
                    dirs << "#{@filerdir}/#{date.year}/#{date.month.pad2}/#{date.day.pad2}/#{hour.pad2}/"
                  end
                end
                (0 .. adj_end_dt.hour).each do |hour|
                  dirs << "#{@filerdir}/#{adj_end_dt.year}/#{adj_end_dt.month.pad2}/#{adj_end_dt.day.pad2}/#{hour.pad2}/"
                end
              end

              files = []

              if dirs.first == dirs.last
                Dir["#{dirs.first}/*"].sort.each do |path|
                  file = File.basename(path)
                  unixtime = file.sub(/#{@fileprefix}\./, '').to_i
                  files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
                end
              else
                Dir["#{dirs.first}/*"].sort.each do |path|
                  file = File.basename(path)
                  unixtime = file.sub(/#{@fileprefix}\./, '').to_i
                  files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
                end
                dirs.to_a[1...-1].each do |dir|
                  Dir["#{dir}/*"].sort.each do |path|
                    files << path
                  end
                end
                Dir["#{dirs.last}/*"].sort.each do |path|
                  file = File.basename(path)
                  unixtime = file.sub(/#{@fileprefix}\./, '').to_i
                  files << path if unixtime >= adj_start_dt.to_i and unixtime <= adj_end_dt.to_i
                end
              end

              files
            end

        end
    end
end
