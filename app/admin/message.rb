ActiveAdmin.register Message do
	permit_params :content, :user_id, :talk_id
  menu parent: 'Admin'

  filter :content

  form do |f|
    f.inputs do
      f.input :content
      f.input :user_id, :label => 'Users', :as => :select, :collection => User.all.map{|u| ["#{u.firstname}, #{u.lastname}", u.id]}
      f.input :talk_id, :label => 'Talk', :as => :select, :collection => Talk.all.map{|t| ["#{t.title}", t.id]}
    end
    f.actions
  end

end
