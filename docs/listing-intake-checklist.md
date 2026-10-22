# Genuine listing intake checklist

Use one record per property. Do not publish until an authorized staff member has checked the source documents and approved the public fields. The blank CSV templates are for data collection only; they do not create or publish records.

## Property facts

- A unique internal record will be assigned by the database; do not invent a property ID.
- Confirm the advertiser is authorized to market the property and retain the reference/evidence securely.
- Use a factual title and description; avoid unsupported claims about ownership, condition, returns, title, amenities or availability.
- Confirm the price, currency (currently displayed as Nigerian naira by the app), sale/rent/off-plan status, property type, bedroom/bathroom counts and feature list with the authorized source.
- Record the actual public neighbourhood/area in `public_location`. Never put a private street address in this field.
- Store the exact address only in the private `address` column when there is a legitimate operational reason.

## Location review

- Use coordinates only when supplied/confirmed by an authorized source; do not geocode or guess a property pin.
- Set `location_verification_status` to `unverified` until a staff review is complete.
- Use `approximate` only when coordinates intentionally represent a neighbourhood/area rather than the exact property.
- Use `verified` only after an authorized staff review with recorded evidence; the public view may then expose the exact address when valid coordinates are present.
- Keep nearby landmarks factual and avoid using them to reveal a private address.

## Photos and video

- Obtain permission/rights to publish every image and video and keep the source/consent record.
- Use stable HTTPS URLs and confirm they load on mobile and web.
- Add media to `PropertyMedia` with the correct `media_type`, order, cover selection and caption.
- Do not set `is_approved=true` until the media has been reviewed. The client only reads approved media.
- For video, confirm the external URL works in the target browsers/devices and uses a supported format. The app opens it externally; it does not host or transcode video.

## Publication review

- Confirm the listing is genuinely active and all public copy/media is approved.
- Set `is_featured` only when intentionally selected by an authorized staff member.
- Set `is_published=true` only after required factual and privacy checks pass and a non-empty safe `public_location` has been provided.
- Preview the listing, exact/approximate location label, cover media, enquiry and inspection paths in staging before production publication.
- Keep a named reviewer and review date in the organization's controlled records; the app database does not replace that evidence workflow.
