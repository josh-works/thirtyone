require 'rails_helper'

describe User do

  it 'should have a valid factory' do
    expect(build(:user)).to be_valid
  end
end

