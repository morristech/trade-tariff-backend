TradeTariffBackend::DataMigrator.migration do
  name 'Assign footnote_id/footnote_type_id 002 05 ECO to list of heading ids and their comodities'

  up do
    applicable {
      # The apply block is idempotent
      true
    }
    apply {

      footnote = Footnote.where(footnote_id: '002', footnote_type_id: '05').first
      commodities = [ "2811110000", "2812120000", "2812130000", "2812140000", "2812150000",
        "2812170000", "2812199000", "2813901000", "2826191000", "2826199000", "2826908000",
        "2830100000", "2837110000", "2837190000", "2837200000", "2905190000", "2905599800",
        "2914199000", "2918170000", "2918199800", "2920190000", "2920210000", "2920220000",
        "2920230000", "2920240000", "2920290000", "2921110000", "2921140000", "2921195000",
        "2921199900", "2922150000", "2922170000", "2922180000", "2922190000", "2929900000",
        "2930700000", "2930909800", "2931310000", "2931330000", "2931392000", "2931393000",
        "2931399000", "2933399900", "3601000000", "3602000000", "3603000000", "3926909700",
        "6307909800", "6506101000", "6506108000", "7229909000", "7504000000", "7603000000",
        "8103900000", "8109900000", "8401100000", "8401400000", "8411000000", "8412000000",
        "8413000000", "8414000000", "8419890000", "8421190000", "8422300000", "8458000000",
        "8459000000", "8460110000", "8460210000", "8479890000", "8481000000", "8504400000",
        "8514100000", "8514200000", "8514300000", "8525800000", "8526000000", "8528590000",
        "8532000000", "8535300000", "8540208000", "8540810000", "8540890000", "8543200000",
        "8543700000", "8702000000", "8705908000", "8708999700", "8710000000", "8802000000",
        "8906100000", "9005800000", "9013200000", "9014200000", "9015000000", "9022190000",
        "9026200000", "9027800000", "9031100000", "9031800000", "2812160000", "9301100000",
        "9301200000", "9301900000", "9302000000", "9303100000", "9303300000", "9303900000",
        "9304000000", "9305100000", "9305200010", "9305200090", "9305910000", "9305990000",
        "9306210000", "9306301000", "9306901000" ,"9306909000", "9307000000"]

      commodities.each do |commodity|
        goods_nomenclature = GoodsNomenclature.where(goods_nomenclature_item_id: commodity).first
        next if goods_nomenclature.footnotes.include?(footnote)
        puts "Associating footnote #{footnote.inspect} with goods nomenclature #{goods_nomenclature.inspect}"
        FootnoteAssociationGoodsNomenclature.associate_footnote_with_goods_nomenclature(goods_nomenclature , footnote)
      end
    }
  end

  down do
    applicable {
      false
    }
    apply {
      # noop
    }
  end
end
