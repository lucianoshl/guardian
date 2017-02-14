RailsAdmin.config do |config|

  config.included_models = [
    Village,
    Report,
    Troop,
    Model::Buildings,
    Config,
    Player,
    Partner,
    Job::Reserve,
    Job::SendAttack,
    Model::Village,
    Model::Troop,
    ApplicationError
  ]

  report_enum =  {
    win: 'https://brs1.tribalwars.com.br/graphic/dots/green.png',
    win_lost: 'https://brs1.tribalwars.com.br/graphic/dots/yellow.png',
    spy: 'https://brs1.tribalwars.com.br/graphic/dots/blue.png',
    spy_lost: 'https://brs1.tribalwars.com.br/graphic/dots/red_blue.png',
    lost: 'https://brs1.tribalwars.com.br/graphic/dots/red.png',
  } 

  config.model Model::Buildings do
    visible false
  end

  config.model Job::Reserve do
    edit do
      field :targets do
        configure :description
      end
    end

    list do
      field :state
      field :target do
        formatted_value do
          "#{bindings[:object].x}|#{bindings[:object].y}"
        end
      end
      field :player
      field :scheduled do
        formatted_value do
          if (!bindings[:object].active_job.nil?)
            run_at = bindings[:object].active_job.run_at
            run_at.strftime("%d/%m - %H:%M:%S") if (!run_at.nil?)
          else
            '-'
          end
        end
      end
    end

  end

  config.model Job::SendAttack do

    edit do
      field :coordinate
      field :origin
      field :troop
      field :event_time
    end

    list do
      field :state
      field :coordinate
      field :origin do
        formatted_value do
          "#{bindings[:object].origin.x}|#{bindings[:object].origin.y}"
        end
      end
      field :event_time
      field :scheduled do
        formatted_value do
          if (!bindings[:object].active_job.nil?)
            run_at = bindings[:object].active_job.run_at
            run_at.strftime("%d/%m - %H:%M:%S") if (!run_at.nil?)
          else
            '-'
          end
        end
      end
      field :snobs do
        formatted_value do
          bindings[:object].troop.snob
        end
      end
    end
  end

  config.model Village do

    edit do
      field :label
      field :use_in_pillage
      field :reserved_troops
      field :model
      field :disable_auto_recruit
    end

    list do
      field :coordinate do
        formatted_value do
          "#{bindings[:object].x}|#{bindings[:object].y}"
        end
      end
      field :label
      field :name
      # field :points
      field :model
      # field :disable_auto_recruit, :toggle
      field :use_in_pillage, :toggle
      field :disable_auto_recruit, :toggle
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

    show do
      field :report  do
        formatted_value do
          bindings[:view].render :partial => "rails_admin/main/report", :locals => {:field => self, :object => bindings[:object] }
        end
      end
    end

  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except [Report,Village]
    end
    # export
    bulk_delete
    show
    edit do
      except [Job::Reserve,Report]
    end
    delete
    show_in_app
    toggle
    charts

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
