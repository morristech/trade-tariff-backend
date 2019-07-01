module Api
  module V2
    class UpdatesController < ApiController
      def latest
        @updates = TariffSynchronizer::BaseUpdate.latest_applied_of_both_kinds

        render json: Api::V2::TariffUpdateSerializer.new(@updates.to_a).serializable_hash
      end
    end
  end
end
