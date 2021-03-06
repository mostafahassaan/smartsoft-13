from django.conf.urls import patterns, url, include
from lists import views

# urlpatterns = patterns('',
# 	# /polls/
#     url(r'^$', views.index, name='index'),
#     # /polls/5
#     url(r'^(?P<poll_id>\d+)/$', views.detail, name='detail'),
#     # /polls/5/results
#     url(r'^(?P<poll_id>\d+)/results/$', views.results, name='results'),
#     # /polls/5/vote
#     url(r'^(?P<poll_id>\d+)/vote/$', views.vote, name='vote'),
# )

urlpatterns = patterns('',
	url(r'^new_list/$', views.new_list, name='new_list'),
	url(r'^new_list$', views.new_list, name='new_list'),
	url('new_list/create_list/', views.create_list, name='create_list'),
	# url('', views.view_lists, name='list_manage'),
	url('lists/create_list/', views.create_list, name='create_list'),
	url('lists/view_lists/', views.view_lists, name='view_lists'),
	url(r'^(?P<list_id>\d+)/$', views.list_details, name='list_detail'),
	url(r'^(?P<list_id>\d+)/(?P<removed_user>\d+)/remove_user/$', views.remove_shared_user, name='remove_shared_user'),
	url(r'^(?P<list_id>\d+)/edit/$', views.edit, name="edit_list_form"),
	url(r'^(?P<list_id>\d+)/edit_list/$', views.edit_list, name="edit_list_action"),
	url(r'^(?P<list_id>\d+)/delete/', views.delete_list, name='delete_list'),
	url(r'^(?P<list_id>\d+)/share/$', views.share, name="share_list_form"),
	url(r'^(?P<list_id>\d+)/share_list/$', views.share_list, name="share_list_action"),
	url(r'^(?P<list_id>\d+)/tasks/(?P<task_id>\d+)/edit$', views.edit_task, name="edit_task"),
	url(r'^(?P<list_id>\d+)/tasks/(?P<task_id>\d+)/delete', views.delete_task, name='delete_task'),
	url(r'^(?P<list_id>\d+)/create_task/', views.create_task, name='create_task'),
	url(r'^(?P<list_id>\d+)/tasks/(?P<task_id>\d+)/edit_task$', views.save_edit_task, name="edit_task_action"),
	url(r'^(?P<list_id>\d+)/tasks/(?P<task_id>\d+)/status$', views.change_state, name="edit_task"),
)