RailsAdmin.config do |config|

  config.included_models = [Village,Report,Troop,Config,Player,Partner,Job::Reserve]

  report_enum =  {
    win: 'https://brs1.tribalwars.com.br/graphic/dots/green.png',
    win_lost: 'https://brs1.tribalwars.com.br/graphic/dots/yellow.png',
    spy: 'https://brs1.tribalwars.com.br/graphic/dots/blue.png',
    spy_lost: 'https://brs1.tribalwars.com.br/graphic/dots/red_blue.png',
    lost: 'https://brs1.tribalwars.com.br/graphic/dots/red.png',
  } 

  config.model Job::Reserve do

    # register do
    #   field :x
    #   field :y
    # end

    list do
      field :state
      field :x
      field :y
      field :active_job do
        formatted_value do
          if (!bindings[:object].active_job.nil?)
            run_at = bindings[:object].active_job.run_at
            run_at.strftime("%d/%m - %H:%M:%S") if (!run_at.nil?)
          end
        end
      end
      # field :active_job do
      #   formatted_value do
      #     binding.pry
      #     "#{bindings[:object].active_job.run_at}"
      #   end
      # end
    end

  end

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
      except [Report,Village]
    end
    # export
    bulk_delete
    show
    edit do
      except [Job::Reserve]
    end
    delete
    show_in_app
    charts

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
