module ApplicationHelper

    def full_title(page_title = '')
        base_title = "valuse"
        if page_title.empty? #何も入っていなかった場合(provide(:title, ""))がなかった場合
            base_title
        else
            page_title +"|"+base_title
        end
    end

end
