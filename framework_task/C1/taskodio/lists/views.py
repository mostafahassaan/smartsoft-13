from django.http import HttpResponse
from django.template import Context, loader, RequestContext
from django.shortcuts import render, render_to_response
from django.contrib.auth import authenticate, login
from lists.models import List
from django.contrib.auth.models import User


def list_manage(request):
	template = loader.get_template('lists/list_manage.html')
	context = Context({
			'error': 'The email you have entered is already in use.',
			'user': request.user
		})
	return HttpResponse(template.render(context))

# s5 create list view redirect
def new_list(request):
	if not request.user.is_authenticated():
		errors = "To create a new list you have to sign up first."
		context = Context({
			'errors': errors,
		})
		# template = loader.get_template('accounts/siginin.html')
		return render_to_response('accounts/signin.html', context, RequestContext(request))
	else:
		title = 'Create a new list'
		context = Context({
			'title': title,
		})
		return render_to_response('lists/new_list.html', context, RequestContext(request))

# s5 create list action from the new list view form
def create_list(request):
# 	# if user is not authenticated
	# return HttpResponse("FUCK!")
	if not request.user.is_authenticated():
		# redirect to the sign in page and send error with it
		context = Context({ 'errors': "You need to sign in before creating a list"})
		return render_to_response('accounts/signin.html', context, RequestContext(request))
	# else the user is authenticated
	else:
		title = request.POST['list_name']
		# if the title is empty redirect to create_list page and state error
		if not title:
			context = Context({ 'list_errors': "You can't enter an empty list name."})
			return render_to_response('lists/new_list.html', context, RequestContext(request))

		# else if the title is not empty
		else:
			# check if the user has a list already by that name
			if request.user.list_set.filter(title=title):
				context = Context({ 'list_errors': "You can't enter an empty list name."})
				return render_to_response('lists/new_list.html', context, RequestContext(request))
			# else if the user doesn't have a list by that name
			else:
				new_list = List(title=title, user=request.user)
				new_list.save()
				return HttpResponse("You have succesffuly created the list %s" % new_list.title)
				# send a dummy response saying that here we will create a list by
				# --- by that name


#s4
def view_lists(request):
	if request.user.is_authenticated():
		user = request.user
		list_name_set = user.list_set.all()
		context = Context({'list_name_set': list_name_set,})
		#return HttpResponse(list_name_set.all())
		# return render(request, 'lists/list_manage.html', context)
		return render_to_response('lists/list_manage.html', context, RequestContext(request))
	else:
		list_name_set = user.list_set.all()
		context = Context({
			'list_name_set': list_name_set,
			'user': user,
		})
		return render(request,'lists/list_manage.html',context)