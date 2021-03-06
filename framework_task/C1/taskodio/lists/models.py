from django.db import models
from django.contrib.auth.models import User

class List(models.Model):
	title = models.CharField(max_length=200)
	user = models.ForeignKey(User, related_name='owner')
	members= models.ManyToManyField(User, related_name='shared')

class Task(models.Model):
	list = models.ForeignKey(List)
	title = models.CharField(max_length=200)
	done = models.BooleanField(default=False)
	desc= models.CharField(max_length=300)
