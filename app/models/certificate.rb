class Certificate < Sequel::Model
  plugin :time_machine

  set_primary_key [:certificate_code, :certificate_type_code]

  one_to_one :certificate_description, primary_key: {}, key: {}, eager_loader_key: [:certificate_code, :certificate_type_code], dataset: -> {
    CertificateDescription.with_actual(CertificateDescriptionPeriod)
                          .join(:certificate_description_periods, certificate_description_periods__certificate_description_period_sid: :certificate_descriptions__certificate_description_period_sid,
                                                                  certificate_description_periods__certificate_type_code: :certificate_descriptions__certificate_type_code,
                                                                  certificate_description_periods__certificate_code: :certificate_descriptions__certificate_code)
                          .where(certificate_description_periods__certificate_code: certificate_code,
                                 certificate_description_periods__certificate_type_code: certificate_type_code)
                          .order(:certificate_description_periods__validity_start_date.desc)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|certificate| certificate.associations[:certificate_description] = nil}

    id_map = eo[:id_map]

    CertificateDescription.join_table(:inner,
                            CertificateDescriptionPeriod.select(Sequel.as(:certificate_description_period_sid, :certificate_description_period_sid))
                                                        .where(certificate_description_periods__certificate_code: id_map.keys.map(&:first),
                                                               certificate_description_periods__certificate_type_code: id_map.keys.map(&:last))
                                                        .order(:certificate_description_periods__validity_start_date.desc),
                            {certificate_descriptions__certificate_description_period_sid: :description_periods__certificate_description_period_sid},
                            {table_alias: 'description_periods'}
                          ).group(:certificate_descriptions__certificate_code,
                                  :certificate_descriptions__certificate_type_code)
                          .all do |certificate_description|
      if certificates = id_map[[certificate_description.certificate_code, certificate_description.certificate_type_code]]
        certificates.each do |certificate|
          certificate.associations[:certificate_description] = certificate_description
        end
      end
    end
  end)

  many_to_one :certificate_type, key: :certificate_type_code,
                                 primary_key: :certificate_type_code

  delegate :description, to: :certificate_description
end


