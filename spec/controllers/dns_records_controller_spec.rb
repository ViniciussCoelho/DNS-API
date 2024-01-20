require 'rails_helper'

RSpec.describe Api::V1::DnsRecordsController, type: :controller do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

  describe '#index' do
    context 'with the required page param' do
      let(:page) { 1 }

      let(:ip1) { '1.1.1.1' }
      let(:ip2) { '2.2.2.2' }
      let(:ip3) { '3.3.3.3' }
      let(:ip4) { '4.4.4.4' }
      let(:ip5) { '5.5.5.5' }
      let(:lorem) { 'lorem.com' }
      let(:ipsum) { 'ipsum.com' }
      let(:dolor) { 'dolor.com' }
      let(:amet) { 'amet.com' }
      let(:sit) { 'sit.com' }

      let(:payload1) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: lorem
              },
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload2) do
        {
          dns_records: {
            ip: ip2,
            hostnames_attributes: [
              {
                hostname: ipsum
              }
            ]
          }
        }.to_json
      end

      let(:payload3) do
        {
          dns_records: {
            ip: ip3,
            hostnames_attributes: [
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload4) do
        {
          dns_records: {
            ip: ip4,
            hostnames_attributes: [
              {
                hostname: ipsum
              },
              {
                hostname: dolor
              },
              {
                hostname: sit
              },
              {
                hostname: amet
              }
            ]
          }
        }.to_json
      end

      let(:payload5) do
        {
          dns_records: {
            ip: ip5,
            hostnames_attributes: [
              {
                hostname: dolor
              },
              {
                hostname: sit
              }
            ]
          }
        }.to_json
      end

      before :each do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload1, format: :json)
        post(:create, body: payload2, format: :json)
        post(:create, body: payload3, format: :json)
        post(:create, body: payload4, format: :json)
        post(:create, body: payload5, format: :json)
      end

      context 'without included and excluded optional params' do
        let(:expected_response) do
          {
            total_records: 5,
            records: [
              {
                id: 6,
                ip_address: ip1
              },
              {
                id: 7,
                ip_address: ip2
              },
              {
                id: 8,
                ip_address: ip3
              },
              {
                id: 9,
                ip_address: ip4
              },
              {
                id: 10,
                ip_address: ip5
              }
            ],
            related_hostnames: [
              {
                count: 1,
                hostname: lorem
              },
              {
                count: 4,
                hostname: ipsum
              },
              {
                count: 4,
                hostname: dolor
              },
              {
                count: 3,
                hostname: amet
              },
              {
                count: 2,
                hostname: sit
              }
            ].sort_by { |h| h[:hostname] }
          }
        end

        before :each do
          get(:index, params: { page: page })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns all dns records with all hostnames' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the included optional param' do
        let(:included) { [ipsum, dolor].join(',') }

        let(:expected_response) do
          {
            total_records: 3,
            records: [
              {
                id: 16,
                ip_address: ip1
              },
              {
                id: 18,
                ip_address: ip3
              },
              {
                id: 19,
                ip_address: ip4
              }
            ],
            related_hostnames: [
              {
                count: 3,
                hostname: amet
              },
              {
                count: 1,
                hostname: lorem
              },
              {
                count: 1,
                hostname: sit
              }
            ].sort_by { |h| h[:hostname] }
          }
        end

        before :each do
          get(:index, params: { page: page, included: included })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the included dns records without a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the excluded optional param' do
        let(:excluded) { [lorem].join(',') }

        let(:expected_response) do
          {
            total_records: 4,
            records: [
              {
                id: 27,
                ip_address: ip2
              },
              {
                id: 28,
                ip_address: ip3
              },
              {
                id: 29,
                ip_address: ip4
              },
              {
                id: 30,
                ip_address: ip5
              }
            ],
            related_hostnames: [
              {
                count: 3,
                hostname: ipsum
              },
              {
                count: 3,
                hostname: dolor
              },
              {
                count: 2,
                hostname: amet
              },
              {
                count: 2,
                hostname: sit
              }
            ].sort_by { |h| h[:hostname] }
          }
        end

        before :each do
          get(:index, params: { page: page, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with both included and excluded optional params' do
        let(:included) { [ipsum, dolor].join(',') }
        let(:excluded) { [sit].join(',') }

        let(:expected_response) do
          {
            total_records: 2,
            records: [
              {
                id: 36,
                ip_address: ip1
              },
              {
                id: 38,
                ip_address: ip3
              }
            ],
            related_hostnames: [
              {
                count: 1,
                hostname: lorem
              },
              {
                count: 2,
                hostname: amet
              }
            ].sort_by { |h| h[:hostname] }
          }
        end

        before :each do
          get(:index, params: { page: page, included: included, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end
    end

    context 'without the required page param' do
      before :each do
        get(:index)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#create' do
    let(:valid_attributes) do
      {
        dns_records: {
          ip: '8.8.8.8',
          hostnames_attributes: [
            { hostname: 'example.com' },
            { hostname: 'test.com' }
          ]
        }
      }
    end

    let(:invalid_attributes) do
      {
        dns_records: {
          ip: '1.1.1.1',
          hostnames_attributes: [
            { hostname: '_badexample.com' }
          ]
        }
      }
    end

    context 'with valid attributes' do
      it 'creates a new DNS record' do
        expect {
          post :create, params: valid_attributes
        }.to change(DnsRecord, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns the id of the created record' do
        post :create, params: valid_attributes
        expect(JSON.parse(response.body)['id']).to eq(DnsRecord.last.id)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new DNS record' do
        expect {
          post :create, params: invalid_attributes
        }.to_not change(DnsRecord, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
