require 'spec_helper'

describe Chief::Tamf do
  describe 'associations' do
    describe 'measure_type_conds' do
      let!(:common) { attributes_for(:measure_type_cond) }
      let!(:tamf)   { create :tamf, msrgp_code: common[:measure_group_code], msr_type: common[:measure_type] }
      let!(:measure_type_cond)  { create :measure_type_cond, common }
      let!(:measure_type_cond_irrelevant) { create :measure_type_cond }

      it 'associates correct Chief measure type conditions' do
        tamf.measure_type_conds.should     include measure_type_cond
        tamf.measure_type_conds.should_not include measure_type_cond_irrelevant
      end
    end
  end

  describe '#mark_as_processed!' do
    let!(:tamf) { create :tamf }

    it 'marks itself as processed' do
      tamf.processed.should be_false
      tamf.mark_as_processed!
      tamf.reload.processed.should be_true
    end
  end

  describe '#geographical_area' do
    before { Chief::Tamf.unrestrict_primary_key }

    it 'picks cngp_code if it is available' do
      tamf = Chief::Tamf.new(cngp_code: 'abc')
      tamf.geographical_area.should eq 'abc'
    end

    it 'picks cntry_orig if cngp_code is unavailable' do
      tamf = Chief::Tamf.new(cntry_orig: 'abc')
      tamf.geographical_area.should eq 'abc'
    end

    it 'picks cntry_disp if cngp_cod and cntry_orig are unavailable' do
      tamf = Chief::Tamf.new(cntry_disp: 'abc')
      tamf.geographical_area.should eq 'abc'
    end
  end

  describe '#measurement_unit' do
    let(:tamf) { build :tamf }

    context 'cmpd_uoq present' do
      it 'fetches Chief::MeasurementUnit with cmpd_uoq as part of the key' do
        Chief::MeasurementUnit.expects(:where).with(spfc_cmpd_uoq: 'abc',
                                                    spfc_uoq: 'def').returns(stub_everything)

        tamf.measurement_unit('abc', 'def')
      end
    end

    context 'cmpd_uoq blank' do
      it 'fetches Chief::MeasurementUnit with uoq as key' do
        Chief::MeasurementUnit.expects(:where)
                              .with(spfc_uoq: 'abc')
                              .returns(stub_everything)

        tamf.measurement_unit(nil, 'abc')
      end
    end
  end
end
