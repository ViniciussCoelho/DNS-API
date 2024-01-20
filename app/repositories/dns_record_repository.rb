class DnsRecordRepository
  def initialize
    @model = DnsRecord
  end

  def dns_records_by_hostname(included: [], excluded: [], page: 1)
    query = @model.joins(:hostnames)
  
    if included.present?
      query = query.where(hostnames: { hostname: included })
      query = query.group('dns_records.id')
      query = query.having('COUNT(dns_records.id) >= ?', included.size)
    end
  
    if excluded.present?
      excluded_records = DnsRecord.joins(:hostnames).where(hostnames: { hostname: excluded }).select('dns_records.id')
      query = query.where.not(id: excluded_records)
    end
  
    query = query.order(:id)
    query = query.distinct
    query.paginate(page: page, per_page: 10)
  end
  
  

  def related_hostnames(included: [], excluded: [], dns_records: nil)
    query = Hostname.joins(:dns_records)
              .where(dns_records: { id: dns_records.pluck(:id) })
              .where.not(hostname: (included + excluded))
              .group(:hostname)
              .order(:hostname)
              .count
  end
end
  