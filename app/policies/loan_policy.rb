class LoanPolicy < ApplicationPolicy
  def show?
    # here we can access our context and record
    user.has_role?(:admin) || (user.id == record.user_id)
  end
end
