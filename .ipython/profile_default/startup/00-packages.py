# ############# pandas helper

def max_rows(n):
    pd.set_option('display.max_rows', n)
    print('pandas max-rows set to %s' % pd.get_option('display.max_rows'))

# ############# prompt


import datetime as dt

try:
    # ipython
    c = get_config()

    from IPython.terminal.prompts import Prompts
    from pygments.token import Token

    class DTPrompt(Prompts):
        def in_prompt_tokens(self):
            return [
                (Token.Prompt, '[ {:%H:%M:%S} ] '.format(dt.datetime.now())),
            ] + super().in_prompt_tokens()

        def out_prompt_tokens(self):
            return [
                (Token.OutPrompt, '[ {:%H:%M:%S} ] '.format(dt.datetime.now())),
            ] + super().out_prompt_tokens()


    c.TerminalInteractiveShell.prompts_class = DTPrompt
except NameError:
    # regular python interpreter
    import sys

    class DTPrompt:
        def __str__(self):
            return '[ {:%H:%M:%S} ] >>> '.format(dt.datetime.now())

    sys.ps1 = DTPrompt()
    sys.ps2='... '

# ############# extra libs

print('- ' * 10)
import datetime as dt
print('import datetime as dt')

try:
    import numpy as np
    print('import numpy as np')
except ImportError:
    pass

try:
    import pandas as pd
    print('import pandas as pd')
    max_rows(100)
except ImportError:
    pass
print('- ' * 10)
