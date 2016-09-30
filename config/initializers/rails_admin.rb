RailsAdmin.config do |config|

  config.included_models = [Village,Report,Troop,Config,Player]

  report_enum =  {
    win: 'https://brs1.tribalwars.com.br/graphic/dots/green.png',
    win_lost: 'https://brs1.tribalwars.com.br/graphic/dots/yellow.png',
    spy: 'https://brs1.tribalwars.com.br/graphic/dots/blue.png',
    spy_lost: 'https://brs1.tribalwars.com.br/graphic/dots/red_blue.png',
    lost: 'https://brs1.tribalwars.com.br/graphic/dots/red.png',
  } 

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.model Village do

    edit do
      field :reserved_troops
      field :use_in_pillage
      field :in_blacklist
    end

    list do
      field :coordinate do
        formatted_value do
          "#{bindings[:object].x} | #{bindings[:object].y}"
        end
      end
      field :name
      field :points
      scopes(Village.scopes.keys - [:page])
    end
  end

  config.model Report do
    list do
      field :status do
        label :hidden => true
        formatted_value do
          bindings[:view].tag(:img, { :src => report_enum[bindings[:object].status] })
        end
      end
      field :target
      field :occurrence
      scopes [:important,:normal]
    end
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except [Report]
    end
    # export
    # bulk_delete
    show
    edit
    # delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
