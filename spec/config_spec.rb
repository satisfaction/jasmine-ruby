require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Jasmine::Config do
  before(:each) do
    @template_dir = File.expand_path(File.join(File.dirname(__FILE__), "../generators/jasmine/templates"))
    @config = Jasmine::Config.new
  end

  describe "configuration" do
    before(:each) do
      @config.stub!(:src_dir).and_return(File.join(@template_dir, "public"))
      @config.stub!(:spec_dir).and_return(File.join(@template_dir, "spec"))
    end

    it "if sources.yaml not found" do
      File.stub!(:exist?).and_return(false)
      @config.src_files.should == []
      @config.stylesheets.should == []
      @config.spec_files.should == ['/javascripts/ExampleSpec.js', '/javascripts/SpecHelper.js']
      @config.mappings.should == {
        '/__root__' => @config.project_root,
        '/__spec__' => @config.spec_dir
      }
    end

    it "if jasmine.yml is empty" do
      @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
      YAML.stub!(:load).and_return(false)
      @config.src_files.should == []
      @config.stylesheets.should == []
      @config.spec_files.should == ['/javascripts/ExampleSpec.js', '/javascripts/SpecHelper.js']
      @config.mappings.should == {
        '/__root__' => @config.project_root,
        '/__spec__' => @config.spec_dir
      }
    end

    it "using default jasmine.yml" do
      @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
      @config.src_files.should == []
      @config.spec_files.should == ['/javascripts/ExampleSpec.js', '/javascripts/SpecHelper.js']
      @config.mappings.should == {
        '/__root__' => @config.project_root,
        '/__spec__' => @config.spec_dir
      }
    end

    it "simple_config stylesheets" do
      @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
      YAML.stub!(:load).and_return({'stylesheets' => ['/foo.css', '/bar.css']})
      Dir.stub!(:glob).and_return do |glob_string|
        glob_string
      end
      @config.stylesheets.should == ['/foo.css', '/bar.css']
    end

    describe "using rails jasmine.yml" do
      before do
         original_glob = Dir.method(:glob)
          Dir.stub!(:glob).and_return do |glob_string|
            if glob_string =~ /public/
              glob_string
            else
              original_glob.call(glob_string)
            end
          end
      end
      describe "with a src_base_url defined" do
        it "loads src over http" do
          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine-rails-with-src-base-url.yml'))
          @config.src_files.should == ['http://localhost:3000/javascripts/prototype.js',
            'http://localhost:3000/javascripts/effects.js',
            'http://localhost:3000/javascripts/controls.js',
            'http://localhost:3000/javascripts/dragdrop.js',
            'http://localhost:3000/javascripts/application.js']
           @config.js_files.should == [
            'http://localhost:3000/javascripts/prototype.js',
            'http://localhost:3000/javascripts/effects.js',
            'http://localhost:3000/javascripts/controls.js',
            'http://localhost:3000/javascripts/dragdrop.js',
            'http://localhost:3000/javascripts/application.js',
              '/__spec__/javascripts/ExampleSpec.js',
              '/__spec__/javascripts/SpecHelper.js',
          ]
        end
      end
      describe "without a src_base_url defined" do
        it "loads src files from the file system" do
          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine-rails.yml'))
          @config.spec_files.should == ['/javascripts/ExampleSpec.js', '/javascripts/SpecHelper.js']
          @config.src_files.should == ['/javascripts/prototype.js',
            '/javascripts/effects.js',
            '/javascripts/controls.js',
            '/javascripts/dragdrop.js',
            '/javascripts/application.js']
          @config.js_files.should == [
            '/javascripts/prototype.js',
              '/javascripts/effects.js',
              '/javascripts/controls.js',
              '/javascripts/dragdrop.js',
              '/javascripts/application.js',
              '/__spec__/javascripts/ExampleSpec.js',
              '/__spec__/javascripts/SpecHelper.js',
          ]
        end
      end
    end

    it "should provide a list of all spec files with full paths" do
      @config.spec_files_full_paths.should == [
        File.join(@template_dir, 'spec/javascripts/ExampleSpec.js'),
          File.join(@template_dir, 'spec/javascripts/SpecHelper.js')
      ]
    end

  end

  it "src_dir uses root when src dir is blank" do
    @config.stub!(:project_root).and_return('some_project_root')
    @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
    YAML.stub!(:load).and_return({'src_dir' => nil})
    @config.src_dir.should == 'some_project_root'
  end

  it "should use correct default yaml config" do
    @config.stub!(:project_root).and_return('some_project_root')
    @config.simple_config_file.should == (File.join('some_project_root', 'spec/javascripts/support/jasmine.yml'))
  end


  it "should provide dir mappings" do
    @config.mappings.should == {
      '/__root__' => @config.project_root,
      '/__spec__' => @config.spec_dir
    }
  end

end
