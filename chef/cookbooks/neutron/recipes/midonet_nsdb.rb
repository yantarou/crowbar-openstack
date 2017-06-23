#
# Copyright 2016 SUSE
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install NSDB. This should be done on dedicated database nodes. For now the
# installation is on neutron-server nodes.

node[:neutron][:platform][:midonet_nsdb_pkgs].each { |p| package p }

service "zookeeper" do
  supports status: true, restart: true
  action [:enable, :start]
end

service "cassandra" do
  supports status: true, restart: true
  action [:enable, :start]
end

template "/etc/cassandra/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner "cassandra"
  group "cassandra"
  mode 0o640
  notifies :restart, "service[cassandra]"
end

service "midonet-cluster" do
  supports status: true, restart: true
  action [:enable, :start]
end

template "/etc/midonet/midonet.conf" do
  source "midonet.conf.erb"
  owner "root"
  group "root"
  mode 0o640
  variables(
    zookeeper_hosts: "#{zookeeper_host_list_with_ports}"
  )
  notifies :restart, "service[midonet-cluster]"
end
