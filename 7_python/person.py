#!/usr/bin/python

from __future__ import print_function

class Person():
    def __init__(self,name,age):
        self.name = name
        self._age = age

    @property
    def age(self):
        return self._age

    @age.setter
    def age(self, age):
        if age < 0 or age > 100:
            raise ValueError('age is not illeagl')
  	self._age = age

obj = Person("Jason",50)

print(obj.age)

obj.age = -1
