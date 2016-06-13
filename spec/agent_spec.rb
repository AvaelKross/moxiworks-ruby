require 'spec_helper'
require 'vcr'

describe MoxiworksPlatform::Agent do
  agent_accesors = [:moxi_works_agent_id, :mls, :accreditation, :address_street,
                    :address_city, :address_state, :address_zip, :office_address_street,
                    :office_address_city, :office_address_state, :office_address_zip,
                    :name, :license, :mobile_phone_number, :home_phone_number,
                    :fax_phone_number, :main_phone_number, :primary_email_address,
                    :secondary_email_address, :languages, :twitter, :google_plus,
                    :facebook, :home_page, :birth_date, :title, :profile_image_url,
                    :profile_thumb_url]

  describe :attr_accessors do
    before :each do
      @agent = MoxiworksPlatform::Agent.new
    end


    context :accessors do
      agent_accesors.each do |attr_accessor|
        it "should return for agent attribute #{attr_accessor}" do
          expect(@agent.send("#{attr_accessor.to_s}")).to eq nil
        end

        it "should allow setting for agent attribute #{attr_accessor}" do
          @agent.send("#{attr_accessor.to_s}=", '1234')
          expect("#{@agent.send("#{attr_accessor.to_s}").to_i}").to eq '1234'
        end
      end
    end
    it 'should raise exception when trying to set an attribute that is not defined' do
          expect {@agent.foobar = 'broked' }.to raise_exception(NoMethodError)
        end
  end

  describe :class_methods do
    let!(:platform_id){'abc123'}
    let!(:platform_secret) { 'secret' }
    let!(:agent_id) { '1234abcd' }

    context :find do
      context :credentials_required do
        it 'should raise a MoxiworksPlatform::AuthorizationError if find is called without authorization' do
          VCR.use_cassette('agent/find/success', record: :none) do
            expect {MoxiworksPlatform::Agent.find(
                moxi_works_agent_id: agent_id) }.to raise_exception(MoxiworksPlatform::Exception::AuthorizationError)
          end
        end
      end

      context :test_response_data_handling do
        before :each do
          MoxiworksPlatform::Credentials.new(platform_id, platform_secret)
        end

        after :each do
          MoxiworksPlatform::Credentials.platform_identifier = nil
          MoxiworksPlatform::Credentials.platform_secret = nil
          MoxiworksPlatform::Credentials.instance = nil
        end

        context :not_found do
          it 'should return a nil Object when find can not find anything' do
            VCR.use_cassette('agent/find/nothing', record: :none) do
              contact = MoxiworksPlatform::Agent.find(moxi_works_agent_id: agent_id)
              expect(contact).to be_nil
            end
          end
        end

        context :full_response do
          full_response = JSON.parse('{"moxi_works_agent_id": "abc123","mls": [ "mls numero uno", "ubermls", "majormls"],"accreditation": "","address_street": "1234 Agent St.","address_city": "Agentville","address_state": "AG","address_zip": "12345","office_address_street": "3456 Office Ln.","office_address_city": "Officeville","office_address_state": "AG","office_address_zip": "12345","name": "Buckminster Fuller","license": "WA # 123456789012-12","mobile_phone_number": "222 333 4567","home_phone_number": "(234) 567-8910","fax_phone_number": "4567891011","main_phone_number": "678) 9101112","office_phone_number": "(234)456-7890","primary_email_address": "the_agent@agentdomain.com","secondary_email_address": "the_agent_alt@otherdomain.com","languages": ["EN"],"twitter": "@agentguy","google_plus": "https://plus.google.com/1234567891011121314/posts","facebook": "https://www.facebook.com/moxiworks/","home_page": "foo.com","birth_date": "31 Dec 1999","title": "REALTOR","profile_image_url": "http://picturererer.com/pics37/ImageStore.dll?id=852087C5D3A533DD&w=200","profile_thumb_url": "http://picturererer.com/pics37/ImageStore.dll?id=852087C5D3A533DD&w=75"}')
          it 'should return a MoxiworksPlatform::Agent Object when find is called' do
            VCR.use_cassette('agent/find/success', record: :none) do
              search_attrs = full_response.select {|key, value| %w(moxi_works_agent_id ).include?(key) }
              contact = MoxiworksPlatform::Agent.find(symbolize_keys(search_attrs))
              expect(contact.class).to eq(MoxiworksPlatform::Agent)
            end
          end

          agent_accesors.each do |attr_accessor|
            it "should have populated attribute #{attr_accessor} when update with all attributes populated" do
              VCR.use_cassette('agent/find/success', record: :none) do
                search_attrs = full_response.select {|key, value| %w(moxi_works_agent_id).include?(key) }
                contact = MoxiworksPlatform::Agent.find(symbolize_keys(search_attrs))
                expect(contact.send(attr_accessor.to_s)).to eq(full_response[attr_accessor.to_s])
              end
            end
          end
        end

        context :empty_response do
          empty_response = JSON.parse( '{"moxi_works_agent_id": "abc123", "mls": [], "accreditation": null, "address_street": null, "address_city": null, "address_state": null, "address_zip": null, "office_address_street": null, "office_address_city": null, "office_address_state": null, "office_address_zip": null, "name": null, "license": null, "mobile_phone_number": null, "home_phone_number": null, "fax_phone_number": null, "main_phone_number": null, "office_phone_number": null, "primary_email_address": null, "secondary_email_address": null, "languages": [], "twitter": null, "google_plus": null, "facebook": null, "home_page": null, "birth_date": null, "title": null, "profile_image_url": null, "profile_thumb_url": null}')
          it 'should return a MoxiworksPlatform::Agent Object when find is called' do
            VCR.use_cassette('agent/find/empty', record: :none) do
              search_attrs = empty_response.select {|key, value| %w(moxi_works_agent_id).include?(key) }
              contact = MoxiworksPlatform::Agent.find(symbolize_keys(search_attrs))
              expect(contact.class).to eq(MoxiworksPlatform::Agent)
            end
          end

          it 'should populate moxi_works_agent_id' do
            VCR.use_cassette('agent/find/empty', record: :none) do
              search_attrs = empty_response.select {|key, value| %w(moxi_works_agent_id).include?(key) }
              contact = MoxiworksPlatform::Agent.find(symbolize_keys(search_attrs))
              expect(contact.moxi_works_agent_id).to eq(empty_response['moxi_works_agent_id'])
            end
          end

          agent_accesors.each do |attr_accessor|
            next if attr_accessor.to_s == 'moxi_works_agent_id'
            it "should not have populated attribute #{attr_accessor} when update with all attributes not populated" do
              VCR.use_cassette('agent/find/empty', record: :none) do
                search_attrs = empty_response.select {|key, value| %w(moxi_works_agent_id).include?(key) }
                contact = MoxiworksPlatform::Agent.find(symbolize_keys(search_attrs))
                expect(contact.send(attr_accessor.to_s)).to eq('').or(be_nil).or(be_an_instance_of(Array))
              end
            end
          end
        end
      end
    end


    end
end