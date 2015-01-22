require 'gamification_util.rb'

module Hooks
  class ControllerWikiEditAfterSaveHook < Redmine::Hook::ViewListener

    include GamificationUtil

    def controller_wiki_edit_after_save(context={})
      if context[:params]
        current_user_id = User.current.id
        project_id = Project.find_by_identifier(context[:params][:project_id]).id


        # gamification_user_update
        if Gamification.exists?({user_id: current_user_id})
          user = Gamification.find_by_user_id(current_user_id)
          user_badge = GamificationBadge.find_by_user_id(current_user_id)

          user.up_point(5)

          # check level
          old_lvl = user.level
          new_lvl = decide_level(user.point)
          user.level = check_level(old_lvl, new_lvl)

          # update user badge
          new_badge = check_badge(user_badge, user.level)
          new_badge.save

          user.save
        end

        # gamification_project_update
        if GamificationProject.exists?({user_id: current_user_id, project_id: project_id})
          user_project = GamificationProject.find_by_user_id_and_project_id(current_user_id, project_id)
          user_project.up_point(5)
          user_project.save
        end

      end

      return ''
    end
  end
end
