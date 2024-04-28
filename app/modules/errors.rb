module Errors
    class InvalidAccessError < StandardError
        def initialize(msg="Invalid access to this operation")
            super(msg)
        end
    end

    class InvalidLoanError < StandardError
        def initialize(msg="Invalid loan")
            super(msg)
        end
    end

    class LoanNotFoundError < StandardError
        def initialize(msg="Loan Not found")
            super(msg)
        end
    end
end
