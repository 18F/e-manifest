require 'rails_helper'

describe ManifestParams do
  before do
    class MyTestController < ApplicationController
      include ManifestParams
      def params
        { manifest: { foo: 'bar', color: '' } }
      end
    end
  end

  it 'filters out empty manifest params' do
    controller = MyTestController.new
    expect(controller.manifest_params).to eq({ foo: 'bar' })
  end
end
