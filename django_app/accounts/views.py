from django.shortcuts import render, redirect
from django.contrib import messages
from .models import Login

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        try:
            user = Login.objects.get(username=username, password=password)
            # Store the roll number in session
            request.session['roll_number'] = user.username
            return render(request, 'home.html', {'roll_number': user.username})
        except Login.DoesNotExist:
            messages.error(request, 'Invalid username or password')

    return render(request, 'login.html')


def register_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        if Login.objects.filter(username=username).exists():
            messages.error(request, 'Username already exists')
        else:
            Login.objects.create(username=username, password=password)
            messages.success(request, 'Registration successful! Please log in.')
            return redirect('login')

    return render(request, 'register.html')


def home_view(request):
    # Display roll number stored in session
    roll_number = request.session.get('roll_number')
    if not roll_number:
        return redirect('login')
    return render(request, 'home.html', {'roll_number': roll_number})


def logout_view(request):
    request.session.flush()
    return redirect('login')
