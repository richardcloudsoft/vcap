require 'spec_helper'

describe App do
  it "must have an owner"
  it "requires a unique name/owner combination"
  it "specifies a runtime and framework"
  it "defaults to 0 instances when initialized" do
    App.new.instances.should be_zero
  end

  describe "#instance_handling" do
    before :each do
      @app = App.create(
        :name      => 'foobar',
        :owner     => @user_a,
        :runtime   => 'ruby18',
        :framework => 'sinatra')
      @app.should be_valid
    end

    it "adds the first instance id correctly" do
      @app.add_instance_id 42
      @app.instance_ids.should == "42"
    end

    it "adds the second instance id correctly" do
      @app.add_instance_id 42
      @app.add_instance_id 48
      @app.instance_ids.should == "42;48"
    end

    it "converts the instance id list from database format" do
      @app.instance_ids = "42;48"
      @app.instance_id_array.should == [ 42, 48 ]
    end

    it "converts the instance id list to database format" do
      @app.instance_id_array = [ 42, 48 ]
      @app.instance_ids.should == "42;48"
    end

    it "counts the number of instances" do
      @app.instance_ids = "42"
      @app.instances.should == 1
      @app.instance_ids = "42;48"
      @app.instances.should == 2
    end

    it "adds a one new instance with the next available id" do
      @app.instance_ids = "0;1;2"
      @app.next_instance_id = 4
      @app.instances = 4
      @app.instance_ids.should == "0;1;2;4"
    end

    it "adds multiple new instance with the next available id" do
      @app.instance_ids = "0;1;2"
      @app.next_instance_id = 4
      @app.instances = 5
      @app.instance_ids.should == "0;1;2;4;5"
    end

    it "removes one instance from the end of the id list" do
      @app.instance_ids = "0;1;2"
      @app.instances = 2
      @app.instance_ids.should == "0;1"
    end

    it "removes multiple instances from the end of the id list" do
      @app.instance_ids = "0;1;2"
      @app.instances = 1
      @app.instance_ids.should == "0"
    end
  end

  describe "#collaborators" do
    before :each do
      @user_a = create_user('a@foo.com', 'a')
      @user_b = create_user('b@foo.com', 'b')

      @app = App.create(
        :name      => 'foobar',
        :owner     => @user_a,
        :runtime   => 'ruby18',
        :framework => 'sinatra')
      @app.should be_valid
    end

    it "includes the owner by default" do
      @app.collaborator?(@user_a).should be_true
    end

    it "can be added" do
      @app.add_collaborator(@user_b)
      @app.collaborator?(@user_b).should be_true
    end

    it "can be removed" do
      @app.remove_collaborator(@user_a)
      @app.collaborator?(@user_a).should be_false
    end
  end

  def create_user(email, pw)
    u = User.new(:email => email)
    u.set_and_encrypt_password(pw)
    u.save
    u.should be_valid
    u
  end
end
