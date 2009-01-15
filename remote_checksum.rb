class RemoteChecksum < Scout::Plugin
  def build_report
    begin
      remote_host = option(:remote_host)
      remote_md5_path = option(:remote_md5_path)
      output = `ssh medicaone.com@backupspace.rimuhosting.com 'md5sum -c /home/medicaone.com/sso-nightly-latest.sql.gz.md5'`
      exitcode = $?.exitstatus.to_i
      output = "Remote Host: #{remote_host}, Remote MD5 Path: #{remote_md5_path}, MD5 output: #{output}, exit code: #{exitcode}"
      report(:md5_exitcode => exitcode)
      if exitcode != 0
        alert(:subject => "Remote Checksum failed for file #{remote_md5_path}", :body => output)
      end
      return exitcode
    rescue Exception => e
      error(:subject => 'Error running Remote Checksum plugin', :body => e)
      return -1
    end
  end
end