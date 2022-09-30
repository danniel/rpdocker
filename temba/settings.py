import copy
import warnings
from django.utils.translation import gettext_lazy as _

from .settings_common import *  # noqa


STORAGE_URL = "http://example.com/media"
BRANDING = {
    "example.com": {
        "slug": "rapidpro",
        "name": "RapidPro",
        "org": "UNICEF",
        "colors": dict(primary="#0c6596"),
        "styles": ["brands/rapidpro/font/style.css"],
        "default_plan": TOPUP_PLAN,
        "welcome_topup": 1000,
        "email": "join@rapidpro.io",
        "support_email": "noreply@example.com",
        "link": "https://example.com",
        "api_link": "https://example.com",
        "docs_link": "http://docs.rapidpro.io",
        "domain": "example.com",
        "ticket_domain": "tickets.rapidpro.io",
        "favico": "brands/rapidpro/rapidpro.ico",
        "splash": "brands/rapidpro/splash.jpg",
        "logo": "brands/rapidpro/logo.png",
        "allow_signups": True,
        "flow_types": ["M", "V", "B", "S"],  # see Flow.FLOW_TYPES
        "location_support": True,
        "tiers": dict(multi_user=0, multi_org=0),
        "bundles": [],
        "welcome_packs": [dict(size=5000, name="Demo Account"), dict(size=100000, name="UNICEF Account")],
        "title": _("Visually build nationally scalable mobile applications"),
        "description": _("Visually build nationally scalable mobile applications from anywhere in the world."),
        "credits": "Copyright &copy; 2012-2022 UNICEF, Nyaruka. All Rights Reserved.",
        "support_widget": False,
    }
}
DEFAULT_BRAND = os.environ.get("DEFAULT_BRAND", "example.com")

ALLOWED_HOSTS = ["*", "https://example.com"]

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://%s:%s/%s" % (REDIS_HOST, REDIS_PORT, REDIS_DB),
        "OPTIONS": {"CLIENT_CLASS": "django_redis.client.DefaultClient"},
    }
}

INTERNAL_IPS = ("127.0.0.1",)

MAILROOM_URL = os.environ.get('MAILROOM_URL', 'http://localhost:8090')
MAILROOM_AUTH_TOKEN = None

INSTALLED_APPS = INSTALLED_APPS + ("storages",)

MIDDLEWARE = ("temba.middleware.ExceptionMiddleware",) + MIDDLEWARE

CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True

warnings.filterwarnings(
    "error", r"DateTimeField .* received a naive datetime", RuntimeWarning, r"django\.db\.models\.fields"
)

STATIC_URL = "/sitestatic/"
