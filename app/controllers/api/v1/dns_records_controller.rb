module Api
  module V1
    class DnsRecordsController < ApplicationController
      def index
        dns_records = DnsRecord.all

        render json: dns_records, status: :ok
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

      def dns_record_params
        params.require(:dns_records).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
