# A time or duration speciﬁed in seconds. The time is stored internally as a 64 bit integer value,
# but it is speciﬁed in two parts: a number part and a modiﬁer part. The number can be an integer
# or a ﬂoating point number. If it is entered in ﬂoating point notation, it will be rounded to the nearest integer.
# The modiﬁer is mandatory and follows the number part, either with or without intervening spaces.
#
# The following modiﬁers are permitted:
# seconds
# minutes
#   (60 seconds)
# hours
#   (3600 seconds)
# days
#   (3600*24 seconds)
# weeks
#   (3600*24*7 seconds)
# months
#   (3600*24*30 seconds)
# quarters
#   (3600*24*91 seconds)
# years
#   (3600*24*365 seconds)
# Any abbreviation of these modiﬁers is also permitted (i.e. seconds may be speciﬁed as sec or s).
# A speciﬁcation of m will be taken as months. The speciﬁcation of a time may have as many
# number/modiﬁer parts as you wish. For example:
#
# 1 week 2 days 3 hours 10 mins
# 1 month 2 days 30 sec
# are valid date speciﬁcations.
type Bareos::Time = Pattern[
  /\A[1-9]\d*\z/,
  /\A([1-9]\d*(\s(sec(onds?)?|m(onths?)?|mins?|minutes?|h(ours?)?|d(ays?)?|w(eeks?)?|q(uarters?)?|y(ears?)?))?)(\s[1-9]\d*(\s(sec(onds?)?|m(onths?)?|mins?|minutes?|h(ours?)?|d(ays?)?|w(eeks?)?|q(uarters?)?|y(ears?)?))?)*\z/,
]
