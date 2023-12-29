struct StringUtil:
    @staticmethod
    fn rjust(s: String, width: Int, fillchar: String = ' ') -> String:
        var ret: String = ""
        for i in range(width - len(s)):
            ret += fillchar
        return ret + s