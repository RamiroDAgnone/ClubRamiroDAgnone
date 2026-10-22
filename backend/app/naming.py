import re
import unicodedata


def _clean(text: str) -> str:
    """Removes accents and anything that is not a letter or a digit."""
    normalized = unicodedata.normalize("NFKD", text)
    without_accents = normalized.encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^A-Za-z0-9]", "", without_accents)


def _part(text: str) -> str:
    """Cleans every word and joins them with underscores."""
    words = (_clean(word) for word in text.split())
    return "_".join(word for word in words if word)


def build_space_name(
    venue_name: str,
    venue_address: str,
    sport: str,
    variant: str | None,
    number: int,
) -> str:
    """Example: Moron_Rivadavia_19850_Futbol_F5_1"""
    parts = [_part(venue_name), _part(venue_address), _part(sport)]
    if variant:
        parts.append(_part(variant))
    parts.append(str(number))
    return "_".join(parts)