ActiveAdmin.register TagBundle do

  menu priority: 21

  filter :title_en
  filter :title_de

  permit_params :title_en, :title_de, :tag_list

  index do
    selectable_column
    column :title_en
    column :title_de
    column :tag_list
    actions
  end

  form do |f|
    f.inputs do
      f.input :title_en
      f.input :title_de
      f.input :tag_list, input_html: { value: f.object.tag_list * ', ' }, label: "Tags"
    end
    f.actions
  end

  # after update redirect to index
  controller do
    def update
      update! do |format|
        format.html { redirect_to admin_tag_bundles_path }
      end
    end
  end


end