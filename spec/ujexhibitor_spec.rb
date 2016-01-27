require 'spec_helper'

describe 'ujexhibitor container' do
  describe command('test -x /opt/zk/bin/zkCli.sh') do
    its(:exit_status) { should eq 0 }
  end

  describe command('java -jar /opt/exhibitor/exhibitor.jar') do
    its(:stdout) { should contain 'Exhibitor v1' }
    its(:exit_status) { should eq 0 }
  end
end
