class RemoteChecksum < Scout::Plugin
  def build_report
    begin
      remote_host = option(:remote_host)
      remote_md5_path = option(:remote_md5_path)
      file_age_threshold_days = option(:file_age_threshold_days).to_i
      output = `ssh #{remote_host} 'md5sum -c #{remote_md5_path}'`
      exitcode = $?.exitstatus.to_i
      output = "Remote Host: #{remote_host}, Remote MD5 Path: #{remote_md5_path}, MD5 output: #{output}, exit code: #{exitcode}"
      #if exitcode != 0
       # alert(:subject => "Remote Checksum failed for file #{remote_md5_path}", :body => output)
      #elsif
        ls_output = `ssh #{remote_host} 'ls -l --time-style=long-iso #{remote_md5_path}'`
        alert(:subject => "Debug 1", :body => ls_output)
        md5_file_dates = ls_output.split("\n").map {|line| datestring = line.split(' ')[5]; Date.strptime(datestring,"%Y-%m-%d") }
        alert(:subject => "Debug 2", :body => md5_file_dates.first.to_s)
        unless md5_file_dates.all? {|date| date > Date.today - file_age_threshold_days}
          alert(:subject => "Remote MD5 Path '#{remote_md5_path}' older than threshold of #{file_age_threshold_days}", :body => ls_output)
          exitcode = 2
        end
      # end
      report(:exit_code => exitcode)
      return exitcode
    rescue Exception => e
      error(:subject => 'Error running Remote Checksum plugin', :body => e)
      return -1
    end
  end
end