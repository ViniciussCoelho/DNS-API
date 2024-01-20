module Api
  module V1
    class DnsRecordsController < ApplicationController
      def index
        return render json: { error: 'page param is required' }, status: :unprocessable_entity unless params[:page].present?

        included = params[:included]&.split(',') || []
        excluded = params[:excluded]&.split(',') || []
        dns_records = dns_record_repository.dns_records_by_hostname(included: included, excluded: excluded, page: params[:page])
        related_hostnames_data = dns_record_repository.related_hostnames(included: included, excluded: excluded, dns_records: dns_records)

        render json: {
          total_records: dns_records.total_entries,
          records: dns_records.map { |record| { id: record.id, ip_address: record.ip } },
          related_hostnames: related_hostnames_data.map { |hostname, count| { hostname: hostname, count: count } }
        }
      end

      def create
        dns_record = DnsRecord.new(dns_record_params)
        if dns_record.save
          render json: { id: dns_record.id }, status: :created
        else
          render json: dns_record.errors, status: :unprocessable_entity
        end
      end

      private

      def dns_record_repository
        @dns_record_repository ||= DnsRecordRepository.new
      end

      def dns_record_params
        params.require(:dns_records).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
