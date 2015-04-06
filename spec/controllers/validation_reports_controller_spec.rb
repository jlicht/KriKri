require 'spec_helper'

describe Krikri::ValidationReportsController, :type => :controller do

  routes { Krikri::Engine.routes }

  describe '#show' do
    login_user

    it 'renders the :show view' do
      get :show, id: 'sourceResource_title', provider: 'nypl'
      expect(response).to render_template('krikri/validation_reports/show')
    end

    it 'sets current provider' do
      expect { get :show, id: 'sourceResource_title', provider: 'nypl' }
        .to change { assigns(:current_provider) }.to('nypl')
    end

    # @todo: these are integration tests, repeating coverage from the
    #   ValidationReport model specs. The interface of ValidationReports
    #   makes this hard to test any other way (short of really nasty)
    #   `allow_any_instance_of` chains.
    context 'with saved items' do
      include_context 'with missing values'

      it 'sets documents for all providers' do
        get :show, id: 'sourceResource_title'

        expect(assigns[:documents].map(&:id))
          .to contain_exactly(empty.rdf_subject.to_s,
                              empty_new_provider.rdf_subject.to_s)
      end

      it 'sets documents by provider' do
        get :show, id: 'sourceResource_title', provider: provider.id

        expect(assigns[:documents].map(&:id))
          .to contain_exactly empty.rdf_subject.to_s
      end

      it 'gives docments with isShownAt' do
        get :show, id: 'sourceResource_title', provider: provider.id

        expect(assigns[:documents].first['isShownAt_id'])
          .not_to be_empty
      end
    end
  end
end
