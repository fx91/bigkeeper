require 'big_keeper/util/logger'
require 'json'

module BigKeeper
  class ListGenerator
    #generate tree print throught console
    def self.generate_tree(home_path, file_path, module_list_dic, version)
      module_branches_dic = {}
      json_data = File.read(file_path)
      dic = JSON.parse(json_data)
      dic.keys.select do |module_name|
          module_branches_dic[module_name] = dic[module_name]
      end
      to_tree(module_branches_dic, branches_name, version)
    end

      #generate json print throught console
    def self.generate_json(file_path, home_branches, version)
      module_branches_dic = {}
      json_data = File.read(file_path)
      module_branches_dic = JSON.parse(json_data)
      to_json(home_branches, module_branches_dic, version)
    end

    def self.to_json(home_branches, module_info_list, version)
      json_array = []
      print_all = version == "all versions"
      home_branches.each do | home_branch_name |
          branch_dic = {}
          involve_modules = []
          module_info_list.collect do | module_info_dic |
            next unless module_info_dic["branches"] != nil
            module_name = module_info_dic["module_name"]
            module_info_dic["branches"].each do | module_branch |
              if module_branch.strip.delete("*") == home_branch_name
                module_current_info = {}
                module_current_info["module_name"] = module_name
                module_current_info["current_branch"] = module_info_dic["current_branch"]
                involve_modules << module_current_info
              end
            end
          end
          branch_dic["home_branche_name"] = home_branch_name
          branch_dic["involve_modules"] = involve_modules
          json_array << branch_dic
      end

      cache_path = File.expand_path("~/Desktop/eleme/LPDTeamiOS/.bigkeeper")
      FileUtils.mkdir_p(cache_path) unless File.exist?(cache_path)
      file = File.new("#{cache_path}/test.json", 'w')
      file << json_array.to_json
      file.close
      json_array
    end

    def self.to_tree(module_branches_dic, branches_name, version)
      home_name = BigkeeperParser.home_name
      print_all = version == "all versions"
      branches_name.each do | branch_name |
        next unless branch_name.include?(version) || print_all
        Logger.highlight(branch_name.strip)
        module_branches_dic.keys.each do |module_name|
          module_branches_dic[module_name].each do |module_branch|
            if module_branch.include?(branch_name.strip.delete('*'))
              if module_branch.include?("*")
                Logger.default("   ├── #{module_name}")
              else
                Logger.warning("   ├── #{module_name} (not current branch)")
              end
                break
            end
          end
        end
      end
    end
  end
end
