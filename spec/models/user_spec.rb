require 'rails_helper'

RSpec.describe User, type: :model do
    describe "user creation" do
        let!(:user) {
            create(:user)
        }

        it "should assign default role" do
            expect(user.has_role?(:customer)).to eq(true)
        end
    end
end
