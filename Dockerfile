# Stage 1: Base build stage
FROM python:3.13 AS builder
 
# Create the app directory
RUN mkdir app

# Set the working directory
WORKDIR app


# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 
ENV SECRET_KEY='django-insecure-6#r6*nj(tp-!4b$-w@gky9x%(^2m^s(f@k0b3f44wmtuo!bb9!'
ENV DEBUG=true
ENV DJANGO_ALLOWED_HOSTS=["*"]



# Upgrade pip and install dependencies
RUN apt-get update -y \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    build-essential \
    gcc

 
# Copy the requirements file first (better caching)
COPY requirements.txt .
 
# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
 
# Stage 2: Production stage
FROM python:3.13-slim
 
RUN useradd -m -r fran321tec && \
   mkdir app && \
   chown -R fran321tec app/
 
# Copy the Python dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
 
# Set the working directory
WORKDIR app
 
# Copy application code
COPY . .


# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 
ENV DEBUG=False
ENV DJANGO_ALLOWED_HOSTS=["*"]

# Switch to non-root user
USER fran321tec
 
# Expose the application port
EXPOSE 8000 


# Start the application using Gunicorn
WORKDIR Seleccion_arkenco

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

